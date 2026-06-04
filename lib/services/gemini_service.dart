import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../state/chat_directive.dart';

class GeminiChatMessage {
  final String role;
  final String text;
  final Map<String, dynamic>? directive;
  final bool directiveResolved;

  const GeminiChatMessage({
    required this.role,
    required this.text,
    this.directive,
    this.directiveResolved = false,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'text': text,
        if (directive != null) 'directive': directive,
        if (directiveResolved) 'directiveResolved': true,
      };
}

class GeminiService {
  GeminiService({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
    http.Client? client,
  }) : _client = client ?? http.Client();

  final String apiKey;
  final String model;
  final http.Client _client;

  static const _endpointBase =
      'https://generativelanguage.googleapis.com/v1beta/models';

  Future<BotReply> generateReply({
    required ChatTurnContext turn,
    required List<GeminiChatMessage> history,
    required String currentRiskLevel,
    required String selectedSymptomsText,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const GeminiServiceException('Missing GEMINI_API_KEY.');
    }

    final uri = Uri.parse('$_endpointBase/$model:generateContent');
    final response = await _client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode(_requestBody(
            turn: turn,
            history: history,
            currentRiskLevel: currentRiskLevel,
            selectedSymptomsText: selectedSymptomsText,
          )),
        )
        .timeout(const Duration(seconds: 24));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw GeminiServiceException(
        'Gemini API failed: HTTP ${response.statusCode}.',
      );
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final text = _extractText(decoded);
    return parseBotReplyJson(text);
  }

  Map<String, dynamic> _requestBody({
    required ChatTurnContext turn,
    required List<GeminiChatMessage> history,
    required String currentRiskLevel,
    required String selectedSymptomsText,
  }) {
    return {
      'systemInstruction': {
        'parts': [
          {'text': _systemPrompt},
        ],
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {
              'text': jsonEncode({
                'currentRiskLevel': currentRiskLevel,
                'selectedSymptomsText': selectedSymptomsText,
                'latestTurn': _turnToJson(turn),
                'history': _historyToJson(history),
              }),
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.7,
        // gemini-2.5-flash is a "thinking" model: its reasoning tokens count
        // against maxOutputTokens. With the full system prompt the thinking
        // alone can use ~750 tokens, so a low cap (e.g. 800) truncated the
        // JSON mid-string (finishReason=MAX_TOKENS) and broke parsing. Keep a
        // comfortable budget so thinking + the structured reply both fit.
        'maxOutputTokens': 2048,
        'responseMimeType': 'application/json',
        'responseJsonSchema': geminiBotReplySchema,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
        {
          'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE',
        },
      ],
    };
  }

  String _extractText(Map<String, dynamic> body) {
    final candidates = body['candidates'];
    if (candidates is! List || candidates.isEmpty) {
      throw const GeminiServiceException('Gemini response has no candidates.');
    }

    final content = candidates.first['content'];
    final parts = content is Map<String, dynamic> ? content['parts'] : null;
    if (parts is! List || parts.isEmpty) {
      throw const GeminiServiceException('Gemini response has no text parts.');
    }

    final text = parts
        .map((part) => part is Map<String, dynamic> ? part['text'] : null)
        .whereType<String>()
        .join()
        .trim();
    if (text.isEmpty) {
      throw const GeminiServiceException('Gemini response text is empty.');
    }
    return text;
  }

  String _extractTextSafe(Map<String, dynamic> body) {
    try {
      final candidates = body['candidates'];
      if (candidates is! List || candidates.isEmpty) return '';
      final content = candidates.first['content'];
      final parts = content is Map<String, dynamic> ? content['parts'] : null;
      if (parts is! List || parts.isEmpty) return '';
      return parts
          .map((part) => part is Map<String, dynamic> ? part['text'] : null)
          .whereType<String>()
          .join();
    } catch (_) {
      return '';
    }
  }

  /// Streaming variant — uses SSE for faster time-to-first-byte.
  /// The JSON response is buffered completely before parsing, but the
  /// connection starts receiving data sooner than the non-streaming call.
  Future<BotReply> generateReplyStreamed({
    required ChatTurnContext turn,
    required List<GeminiChatMessage> history,
    required String currentRiskLevel,
    required String selectedSymptomsText,
    void Function(String partialText)? onPartialText,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw const GeminiServiceException('Missing GEMINI_API_KEY.');
    }

    final uri = Uri.parse('$_endpointBase/$model:streamGenerateContent?alt=sse');
    final request = http.Request('POST', uri);
    request.headers['Content-Type'] = 'application/json';
    request.headers['x-goog-api-key'] = apiKey;
    request.body = jsonEncode(_requestBody(
      turn: turn,
      history: history,
      currentRiskLevel: currentRiskLevel,
      selectedSymptomsText: selectedSymptomsText,
    ));

    final response = await _client.send(request).timeout(const Duration(seconds: 30));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final body = await response.stream.bytesToString();
      throw GeminiServiceException(
        'Gemini API failed: HTTP ${response.statusCode}. $body',
      );
    }

    // SSE format: lines starting with 'data: ' contain JSON chunks
    final buffer = StringBuffer();
    await for (final chunk in response.stream.transform(utf8.decoder)) {
      // Each SSE event is 'data: {...}\n\n'
      for (final line in chunk.split('\n')) {
        final trimmed = line.trim();
        if (trimmed.startsWith('data: ')) {
          final jsonStr = trimmed.substring(6); // remove 'data: ' prefix
          try {
            final parsed = jsonDecode(jsonStr) as Map<String, dynamic>;
            final text = _extractTextSafe(parsed);
            if (text.isNotEmpty) {
              buffer.write(text);
              if (onPartialText != null) {
                final match = RegExp(r'"text"\s*:\s*"((?:[^"\\]|\\.)*)').firstMatch(buffer.toString());
                if (match != null) {
                  String extracted = match.group(1) ?? '';
                  extracted = extracted.replaceAll('\\n', '\n').replaceAll('\\"', '"').replaceAll('\\\\', '\\');
                  onPartialText(extracted);
                }
              }
            }
          } catch (_) {
            // Skip non-JSON lines
          }
        }
      }
    }

    final fullText = buffer.toString().trim();
    if (fullText.isEmpty) {
      throw const GeminiServiceException('Gemini streaming response is empty.');
    }
    return parseBotReplyJson(fullText);
  }

  List<Map<String, dynamic>> _historyToJson(List<GeminiChatMessage> messages) {
    final recent = messages.length > 16
        ? messages.sublist(messages.length - 16)
        : messages;
    return recent.map((m) => m.toJson()).toList();
  }

  Map<String, dynamic> _turnToJson(ChatTurnContext turn) => {
        'userText': turn.userText,
        if (turn.directiveId != null) 'directiveId': turn.directiveId,
        if (turn.selectedValue != null) 'selectedValue': turn.selectedValue,
        if (turn.selectedValues != null) 'selectedValues': turn.selectedValues,
        if (turn.sliderValue != null) 'sliderValue': turn.sliderValue,
        'isFreeText': turn.isFreeText,
      };
}

BotReply parseBotReplyJson(String rawJson) {
  final decoded = jsonDecode(rawJson);
  if (decoded is! Map<String, dynamic>) {
    throw const GeminiServiceException('Bot reply must be a JSON object.');
  }

  final text = decoded['text'];
  if (text is! String || text.trim().isEmpty) {
    throw const GeminiServiceException('Bot reply text is required.');
  }

  final directive = _parseDirective(decoded['directive']);
  final risk = decoded['setRiskLevel'];
  if (risk != null && !_validRiskLevels.contains(risk)) {
    throw GeminiServiceException('Invalid risk level: $risk.');
  }

  return BotReply(
    text: text.trim(),
    directive: directive,
    setSymptomsText: decoded['setSymptomsText'] as String?,
    setRiskLevel: risk as String?,
    triggerBooking: decoded['triggerBooking'] as bool? ?? false,
  );
}

ChatUiDirective? _parseDirective(dynamic raw) {
  if (raw == null) return null;
  if (raw is! Map<String, dynamic>) {
    throw const GeminiServiceException('directive must be an object or null.');
  }

  final directive = ChatUiDirective.fromJson(raw);
  _validateDirective(directive);
  return directive.type == ChatComponentType.none ? null : directive;
}

void _validateDirective(ChatUiDirective directive) {
  if (directive.directiveId.trim().isEmpty) {
    throw const GeminiServiceException('directiveId is required.');
  }

  switch (directive.type) {
    case ChatComponentType.none:
    case ChatComponentType.retryButton:
    case ChatComponentType.emergencyAlert:
      return;
    case ChatComponentType.quickPickChips:
    case ChatComponentType.multiSelectChips:
    case ChatComponentType.yesNo:
    case ChatComponentType.bodyPartPicker:
      if (directive.options.isEmpty) {
        throw GeminiServiceException(
            '${directive.type.name} requires options.');
      }
      break;
    case ChatComponentType.severitySlider:
      if (directive.slider == null) {
        throw const GeminiServiceException('severitySlider requires slider.');
      }
      break;
    case ChatComponentType.timeRangePicker:
      if (directive.timeRanges.isEmpty) {
        throw const GeminiServiceException(
          'timeRangePicker requires timeRanges.',
        );
      }
      break;
    case ChatComponentType.reportSummary:
      if (directive.report == null) {
        throw const GeminiServiceException('reportSummary requires report.');
      }
      if (!_validRiskLevels.contains(directive.report!.riskLevel)) {
        throw GeminiServiceException(
          'Invalid report risk: ${directive.report!.riskLevel}.',
        );
      }
      break;
  }
}

const _validRiskLevels = {'Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'};

const Map<String, dynamic> geminiBotReplySchema = {
  'type': 'object',
  'properties': {
    'text': {'type': 'string'},
    'directive': {
      'type': 'object',
      'properties': {
        'type': {
          'type': 'string',
          'enum': [
            'none',
            'quickPickChips',
            'multiSelectChips',
            'severitySlider',
            'timeRangePicker',
            'yesNo',
            'bodyPartPicker',
            'reportSummary',
            'emergencyAlert',
          ],
        },
        'prompt': {'type': 'string'},
        'options': {
          'type': 'array',
          'items': _chatOptionSchema,
        },
        'slider': {
          'type': 'object',
          'properties': {
            'min': {'type': 'number'},
            'max': {'type': 'number'},
            'divisions': {'type': 'integer'},
            'minLabel': {'type': 'string'},
            'maxLabel': {'type': 'string'},
            'unitSuffix': {'type': 'string'},
          },
        },
        'timeRanges': {
          'type': 'array',
          'items': _chatOptionSchema,
        },
        'report': {
          'type': 'object',
          'properties': {
            'chiefComplaint': {'type': 'string'},
            'associated': {
              'type': 'array',
              'items': {'type': 'string'},
            },
            'severity': {'type': 'integer'},
            'duration': {'type': 'string'},
            'riskLevel': {
              'type': 'string',
              'enum': ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'],
            },
            'recommendation': {'type': 'string'},
            'suggestedSpecialty': {'type': 'string'},
          },
          'required': ['chiefComplaint', 'riskLevel'],
        },
        'allowFreeText': {'type': 'boolean'},
        'directiveId': {'type': 'string'},
      },
      'required': ['type', 'directiveId'],
    },
    'setSymptomsText': {'type': 'string'},
    'setRiskLevel': {
      'type': 'string',
      'enum': ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'],
    },
    'triggerBooking': {'type': 'boolean'},
  },
  'required': ['text'],
};

const Map<String, dynamic> _chatOptionSchema = {
  'type': 'object',
  'properties': {
    'label': {'type': 'string'},
    'value': {'type': 'string'},
    'icon': {
      'type': 'string',
      'enum': [
        'head',
        'stomach',
        'heart',
        'fever',
        'lungs',
        'chest',
        'back',
        'limb',
        'dizzy',
        'nausea',
        'light',
        'time',
        'check',
        'close',
      ],
    },
    'riskHint': {
      'type': 'string',
      'enum': ['Thấp', 'Trung bình', 'Cao', 'Khẩn cấp'],
    },
    'nextNodeId': {'type': 'string'},
  },
  'required': ['label', 'value'],
};

const _systemPrompt = '''
Bạn là chuyên viên y tế AI thân thiện, thấu cảm của ứng dụng DrAI.

Nhiệm vụ:
- Giao tiếp tự nhiên, thân thiện và cá nhân hóa. Hãy đóng vai một người tư vấn tận tâm, lắng nghe và đưa ra những tư vấn y tế sơ bộ một cách linh hoạt. Hãy giải thích, an ủi hoặc trò chuyện như một người bạn, thay vì chỉ liên tục đặt câu hỏi theo khuôn mẫu.
- LUÔN TRẢ VỀ ĐÚNG MỘT OBJECT JSON theo schema yêu cầu. KHÔNG bọc bằng markdown (```json).
- TRONG TRƯỜNG "text", CHỈ ĐƯỢC VIẾT VĂN BẢN THÔNG THƯỜNG (TEXT). TUYỆT ĐỐI KHÔNG LỒNG THÊM JSON VÀO TRONG TRƯỜNG "text".
- Không chẩn đoán chắc chắn, không kê đơn chắc chắn, không thay thế bác sĩ.
- Luôn khuyến nghị gọi cấp cứu hoặc mở SOS khi có dấu hiệu khẩn cấp.

Sử dụng UI components (directives):
- Bạn CÓ THỂ thêm "directive" vào JSON nếu nó giúp người dùng trả lời nhanh (quickPickChips, multiSelectChips, vv.), nhưng KHÔNG BẮT BUỘC. Nếu không cần, chỉ trả về JSON có trường "text", bỏ qua "directive".

Quy tắc khẩn cấp:
- Nếu có triệu chứng nguy kịch (đau ngực kèm khó thở, ngất, vã mồ hôi lạnh, yếu liệt đột ngột, chảy máu nặng, sốc phản vệ...): trả về type = "emergencyAlert", kèm theo lời khuyên rõ ràng yêu cầu bệnh nhân đến ngay bệnh viện hoặc gọi cấp cứu 115. Đặt setRiskLevel = "Khẩn cấp".
- Nếu nguy cơ cao nhưng chưa cấp cứu: setRiskLevel = "Cao" và ưu tiên reportSummary/đặt lịch sớm.

Quy tắc UI khác:
- Nếu user text là "__OPENING__", hãy chào hỏi thật tự nhiên và ấm áp, hỏi xem người dùng đang gặp vấn đề gì (ví dụ: "Chào bạn, tôi là Trợ lý DrAI. Hôm nay bạn cảm thấy trong người thế nào? Tôi có thể giúp gì cho bạn?").
- directiveId phải vô cùng ngắn gọn, dưới 20 ký tự (ví dụ: "chat1", "fever_ask"). TUYỆT ĐỐI KHÔNG sinh chuỗi ID dài ngoằn.
- Khi đủ thông tin, hãy trả về reportSummary và setSymptomsText bằng đoạn tóm tắt để người dùng dễ dàng đặt lịch khám.
''';

class GeminiServiceException implements Exception {
  final String message;
  const GeminiServiceException(this.message);

  @override
  String toString() => 'GeminiServiceException: $message';
}
