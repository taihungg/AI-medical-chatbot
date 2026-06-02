import 'package:flutter/material.dart';
import 'chat_directive.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Scripted conversation engine (MVP stand-in for Gemini).
///
/// The conversation is expressed as DATA: a map of [ScriptedNode]s keyed by id.
/// Each node declares the bot text + the interactive directive it emits. The
/// resolver ([_nextNodeId]) maps the user's answer to the next node. Reading
/// this graph is meant to feel like reading the JSON spec Gemini will produce.
///
/// [ConversationEngine] accumulates the user's answers across turns and is the
/// single place the seam (AppState._generateBotReply) delegates to. To swap in
/// Gemini later, AppState calls the Gemini client instead of [next] — nothing
/// in the UI changes.
/// ─────────────────────────────────────────────────────────────────────────

/// One node in the scripted decision tree.
class ScriptedNode {
  final String id;

  /// Produces the bot reply for arriving AT this node (its question + the
  /// interactive component to show). [answers] is the accumulated state so a
  /// node like `wrapup` can build a report from earlier answers.
  final BotReply Function(Map<String, dynamic> answers) build;

  const ScriptedNode({required this.id, required this.build});
}

/// Holds per-conversation accumulated answers and walks the graph.
class ConversationEngine {
  final Map<String, dynamic> _answers = {};
  int _freeTextTurns = 0;

  void reset() {
    _answers.clear();
    _freeTextTurns = 0;
  }

  /// The opening bot turn — used by AppState on init / reset.
  BotReply opening() {
    reset();
    return _graph['root']!.build(_answers);
  }

  /// Compute the next bot reply given the latest user action.
  BotReply next(ChatTurnContext ctx) {
    // Free text (no directive answered): keyword triage / fallback path.
    if (ctx.isFreeText) {
      return _handleFreeText(ctx.userText);
    }

    // Record the answer keyed by the directive that was answered.
    _record(ctx);

    // Advance to the next node based on the directive just answered.
    final nextId = _nextNodeId(ctx);
    final node = _graph[nextId] ?? _graph['wrapup']!;
    return node.build(_answers);
  }

  // ── answer accumulation ───────────────────────────────────────────────────

  void _record(ChatTurnContext ctx) {
    final id = ctx.directiveId ?? '';
    if (ctx.selectedValues != null) {
      _answers['${id}_values'] = ctx.selectedValues;
    } else if (ctx.sliderValue != null) {
      _answers['${id}_slider'] = ctx.sliderValue;
    } else if (ctx.selectedValue != null) {
      _answers[id] = ctx.selectedValue;
    }
  }

  /// Decide the next node id from which directive was just answered.
  String _nextNodeId(ChatTurnContext ctx) {
    final id = ctx.directiveId ?? '';
    switch (id) {
      case 'root':
        return _rootNextById(ctx.selectedValue);
      case 'emergency_check':
        return ctx.selectedValue == 'yes' ? 'emergency_sos' : 'severity';
      case 'dau_dau_detail':
      case 'dau_bung_detail':
      case 'sot_detail':
      case 'ho_detail':
        return 'severity';
      case 'severity':
        return 'onset';
      case 'onset':
        return 'wrapup';
      default:
        return 'wrapup';
    }
  }

  String _rootNextById(String? value) {
    switch (value) {
      case 'dau_dau':
        return 'dau_dau_detail';
      case 'dau_bung':
        return 'dau_bung_detail';
      case 'dau_nguc':
        return 'emergency_check';
      case 'sot':
        return 'sot_detail';
      case 'ho':
        return 'ho_detail';
      default:
        return 'severity';
    }
  }

  // ── derived report fields ─────────────────────────────────────────────────

  String get _chiefComplaintLabel {
    switch (_answers['root']) {
      case 'dau_dau':
        return 'Đau đầu';
      case 'dau_bung':
        return 'Đau bụng';
      case 'dau_nguc':
        return 'Đau ngực';
      case 'sot':
        return 'Sốt';
      case 'ho':
        return 'Ho / Vấn đề hô hấp';
      default:
        return 'Triệu chứng chung';
    }
  }

  String get _suggestedSpecialty {
    switch (_answers['root']) {
      case 'dau_dau':
        return 'Khoa Thần kinh';
      case 'dau_nguc':
        return 'Khoa Tim mạch';
      case 'ho':
        return 'Khoa Hô hấp';
      case 'dau_bung':
        return 'Khoa Tiêu hóa';
      default:
        return 'Khoa Nội tổng quát';
    }
  }

  List<String> _associatedLabels() {
    final detailKey = _answers.keys.firstWhere(
      (k) => k.endsWith('_detail_values'),
      orElse: () => '',
    );
    if (detailKey.isEmpty) return const [];
    final values = (_answers[detailKey] as List?)?.cast<String>() ?? const [];
    return values.map(_associatedLabel).toList();
  }

  String _associatedLabel(String value) {
    const map = {
      'buon_non': 'Buồn nôn',
      'so_anh_sang': 'Sợ ánh sáng',
      'nua_dau': 'Đau nửa đầu',
      'chong_mat': 'Chóng mặt',
      'tieu_chay': 'Tiêu chảy',
      'no_hoi': 'Đầy hơi',
      'quan_dau': 'Quặn đau từng cơn',
      'sot_cao': 'Sốt cao trên 39°C',
      'ret_run': 'Rét run',
      'do_mo_hoi': 'Đổ mồ hôi',
      'ho_dam': 'Ho có đờm',
      'kho_tho_nhe': 'Khó thở nhẹ',
      'dau_hong': 'Đau họng',
    };
    return map[value] ?? value;
  }

  int _severity() {
    final v = _answers['severity_slider'];
    return v is double ? v.round() : 0;
  }

  String _durationLabel() {
    switch (_answers['onset']) {
      case 'under_24h':
        return 'Dưới 24 giờ';
      case '1_3_days':
        return '1 - 3 ngày';
      case 'over_3_days':
        return 'Hơn 3 ngày';
      default:
        return '';
    }
  }

  String _computeRisk() {
    final root = _answers['root'];
    final sev = _severity();
    if (root == 'dau_nguc') return sev >= 7 ? 'Khẩn cấp' : 'Cao';
    if (root == 'sot' && sev >= 6) return 'Cao';
    if (sev >= 7) return 'Cao';
    if (sev >= 4 || _answers['onset'] == 'over_3_days') return 'Trung bình';
    return 'Thấp';
  }

  // ── the graph ─────────────────────────────────────────────────────────────

  late final Map<String, ScriptedNode> _graph = {
    'root': ScriptedNode(
      id: 'root',
      build: (_) => const BotReply(
        text:
            'Xin chào! Tôi là Trợ lý AI Care Bridge. Bạn đang cảm thấy khó chịu nhất ở đâu? Hãy chọn bên dưới hoặc nhắn mô tả triệu chứng của bạn.',
        directive: ChatUiDirective(
          type: ChatComponentType.quickPickChips,
          directiveId: 'root',
          prompt: 'Triệu chứng chính',
          options: [
            ChatOption(label: 'Đau đầu', value: 'dau_dau', icon: Icons.psychology_alt),
            ChatOption(label: 'Đau bụng', value: 'dau_bung', icon: Icons.sick),
            ChatOption(label: 'Đau ngực', value: 'dau_nguc', icon: Icons.monitor_heart, riskHint: 'Khẩn cấp'),
            ChatOption(label: 'Sốt', value: 'sot', icon: Icons.thermostat),
            ChatOption(label: 'Ho / Hô hấp', value: 'ho', icon: Icons.air),
          ],
        ),
      ),
    ),
    'dau_dau_detail': ScriptedNode(
      id: 'dau_dau_detail',
      build: (_) => const BotReply(
        text: 'Cơn đau đầu của bạn có kèm theo triệu chứng nào dưới đây không?',
        directive: ChatUiDirective(
          type: ChatComponentType.multiSelectChips,
          directiveId: 'dau_dau_detail',
          prompt: 'Chọn các triệu chứng kèm theo (có thể chọn nhiều)',
          options: [
            ChatOption(label: 'Buồn nôn', value: 'buon_non', icon: Icons.water_drop),
            ChatOption(label: 'Sợ ánh sáng', value: 'so_anh_sang', icon: Icons.light_mode),
            ChatOption(label: 'Đau nửa đầu', value: 'nua_dau', icon: Icons.psychology_alt),
            ChatOption(label: 'Chóng mặt', value: 'chong_mat', icon: Icons.blur_on),
          ],
        ),
      ),
    ),
    'dau_bung_detail': ScriptedNode(
      id: 'dau_bung_detail',
      build: (_) => const BotReply(
        text: 'Bạn mô tả thêm về cơn đau bụng nhé. Có kèm triệu chứng nào không?',
        directive: ChatUiDirective(
          type: ChatComponentType.multiSelectChips,
          directiveId: 'dau_bung_detail',
          prompt: 'Chọn các triệu chứng kèm theo',
          options: [
            ChatOption(label: 'Buồn nôn', value: 'buon_non', icon: Icons.water_drop),
            ChatOption(label: 'Tiêu chảy', value: 'tieu_chay'),
            ChatOption(label: 'Đầy hơi', value: 'no_hoi'),
            ChatOption(label: 'Quặn đau từng cơn', value: 'quan_dau'),
          ],
        ),
      ),
    ),
    'sot_detail': ScriptedNode(
      id: 'sot_detail',
      build: (_) => const BotReply(
        text: 'Tình trạng sốt của bạn như thế nào?',
        directive: ChatUiDirective(
          type: ChatComponentType.multiSelectChips,
          directiveId: 'sot_detail',
          prompt: 'Chọn các dấu hiệu đi kèm',
          options: [
            ChatOption(label: 'Sốt cao trên 39°C', value: 'sot_cao', icon: Icons.thermostat),
            ChatOption(label: 'Rét run', value: 'ret_run'),
            ChatOption(label: 'Đổ mồ hôi', value: 'do_mo_hoi'),
            ChatOption(label: 'Đau đầu', value: 'nua_dau', icon: Icons.psychology_alt),
          ],
        ),
      ),
    ),
    'ho_detail': ScriptedNode(
      id: 'ho_detail',
      build: (_) => const BotReply(
        text: 'Bạn cho tôi biết thêm về tình trạng ho / hô hấp nhé.',
        directive: ChatUiDirective(
          type: ChatComponentType.multiSelectChips,
          directiveId: 'ho_detail',
          prompt: 'Chọn các triệu chứng kèm theo',
          options: [
            ChatOption(label: 'Ho có đờm', value: 'ho_dam'),
            ChatOption(label: 'Khó thở nhẹ', value: 'kho_tho_nhe', icon: Icons.air),
            ChatOption(label: 'Đau họng', value: 'dau_hong'),
            ChatOption(label: 'Sốt', value: 'sot_cao', icon: Icons.thermostat),
          ],
        ),
      ),
    ),
    'emergency_check': ScriptedNode(
      id: 'emergency_check',
      build: (_) => const BotReply(
        text:
            'Đau ngực có thể là dấu hiệu cần lưu ý. Bạn có kèm theo KHÓ THỞ, vã mồ hôi lạnh, hoặc đau lan ra cánh tay/hàm không?',
        setRiskLevel: 'Khẩn cấp',
        directive: ChatUiDirective(
          type: ChatComponentType.yesNo,
          directiveId: 'emergency_check',
          options: [
            ChatOption(label: 'Có', value: 'yes', icon: Icons.check_circle_outline, riskHint: 'Khẩn cấp'),
            ChatOption(label: 'Không', value: 'no', icon: Icons.cancel_outlined),
          ],
        ),
      ),
    ),
    'emergency_sos': ScriptedNode(
      id: 'emergency_sos',
      build: (_) => const BotReply(
        text:
            'Đây có thể là tình huống cấp cứu. Tôi đang mở màn hình gọi cấp cứu 115 cho bạn. Nếu đây là nhầm lẫn, bạn có thể huỷ ngay.',
        setRiskLevel: 'Khẩn cấp',
        triggerEmergencySos: true,
      ),
    ),
    'severity': ScriptedNode(
      id: 'severity',
      build: (_) => const BotReply(
        text: 'Mức độ khó chịu / đau đớn hiện tại của bạn là bao nhiêu?',
        directive: ChatUiDirective(
          type: ChatComponentType.severitySlider,
          directiveId: 'severity',
          prompt: 'Kéo thanh để đánh giá (1 = nhẹ, 10 = rất nặng)',
          slider: SliderSpec(),
        ),
      ),
    ),
    'onset': ScriptedNode(
      id: 'onset',
      build: (_) => const BotReply(
        text: 'Triệu chứng này đã xuất hiện được bao lâu rồi?',
        directive: ChatUiDirective(
          type: ChatComponentType.timeRangePicker,
          directiveId: 'onset',
          timeRanges: [
            ChatOption(label: 'Dưới 24h', value: 'under_24h', icon: Icons.schedule),
            ChatOption(label: '1 - 3 ngày', value: '1_3_days', icon: Icons.schedule),
            ChatOption(label: 'Hơn 3 ngày', value: 'over_3_days', icon: Icons.schedule),
          ],
        ),
      ),
    ),
    'wrapup': ScriptedNode(id: 'wrapup', build: (a) => _buildWrapup(a)),
  };

  BotReply _buildWrapup(Map<String, dynamic> answers) {
    final chief = _chiefComplaintLabel;
    final associated = _associatedLabels();
    final severity = _severity();
    final duration = _durationLabel();
    final risk = _computeRisk();
    final specialty = _suggestedSpecialty;

    final recommendation = risk == 'Khẩn cấp'
        ? 'Tình trạng của bạn cần được thăm khám khẩn cấp. Hãy đặt lịch ngay hoặc gọi cấp cứu.'
        : risk == 'Cao'
            ? 'Bạn nên đặt lịch khám với bác sĩ chuyên khoa trong vòng 24 giờ tới.'
            : 'Dựa trên thông tin bạn cung cấp, tôi khuyên bạn nên đặt lịch khám để được bác sĩ đánh giá kỹ hơn.';

    final report = ReportData(
      chiefComplaint: chief,
      associated: associated,
      severity: severity,
      duration: duration,
      riskLevel: risk,
      recommendation: recommendation,
      suggestedSpecialty: specialty,
    );

    return BotReply(
      text:
          'Cảm ơn bạn đã chia sẻ. Tôi đã tổng hợp tình trạng của bạn thành báo cáo dưới đây. $recommendation',
      setSymptomsText: report.toBookingSummaryString(),
      setRiskLevel: risk,
      directive: ChatUiDirective(
        type: ChatComponentType.reportSummary,
        directiveId: 'report',
        report: report,
      ),
    );
  }

  // ── free-text fallback (keyword triage) ───────────────────────────────────

  BotReply _handleFreeText(String text) {
    _freeTextTurns++;
    final lower = text.toLowerCase();

    final emergency = lower.contains('đau ngực') ||
        lower.contains('khó thở') ||
        lower.contains('ngất') ||
        lower.contains('cấp cứu');
    final high = lower.contains('sốt cao') ||
        lower.contains('đau dữ dội') ||
        lower.contains('mệt nhiều') ||
        lower.contains('co giật');

    if (emergency || high) {
      final risk = emergency ? 'Khẩn cấp' : 'Cao';
      final report = ReportData(
        chiefComplaint: text.trim().isEmpty ? 'Triệu chứng khai báo tự do' : text.trim(),
        riskLevel: risk,
        recommendation: risk == 'Khẩn cấp'
            ? 'Tình trạng của bạn cần được thăm khám khẩn cấp.'
            : 'Bạn nên đặt lịch khám sớm với bác sĩ chuyên khoa.',
        suggestedSpecialty: emergency ? 'Khoa Tim mạch' : 'Khoa Nội tổng quát',
      );
      return BotReply(
        text:
            'Dựa trên mô tả của bạn, tôi khuyên bạn nên được bác sĩ thăm khám. Tôi đã tổng hợp báo cáo bên dưới.',
        setSymptomsText: report.toBookingSummaryString(),
        setRiskLevel: risk,
        directive: ChatUiDirective(
          type: ChatComponentType.reportSummary,
          directiveId: 'report',
          report: report,
        ),
      );
    }

    if (_freeTextTurns >= 3) {
      final report = ReportData(
        chiefComplaint: text.trim().isEmpty ? 'Triệu chứng khai báo tự do' : text.trim(),
        riskLevel: 'Trung bình',
        recommendation: 'Bạn nên đặt lịch khám để bác sĩ đánh giá chi tiết hơn.',
        suggestedSpecialty: 'Khoa Nội tổng quát',
      );
      return BotReply(
        text:
            'Cảm ơn bạn đã chia sẻ thêm. Để chắc chắn, tôi nghĩ bạn nên đặt lịch khám với bác sĩ. Đây là báo cáo tổng hợp của bạn:',
        setSymptomsText: report.toBookingSummaryString(),
        setRiskLevel: 'Trung bình',
        directive: ChatUiDirective(
          type: ChatComponentType.reportSummary,
          directiveId: 'report',
          report: report,
        ),
      );
    }

    final followups = [
      'Tôi đã ghi nhận. Bạn có thể cho biết triệu chứng xuất hiện bao lâu rồi và có kèm dấu hiệu nào khác không?',
      'Cảm ơn bạn. Mức độ ảnh hưởng đến sinh hoạt hàng ngày của bạn ra sao?',
    ];
    final idx = (_freeTextTurns - 1).clamp(0, followups.length - 1);
    return BotReply(text: followups[idx], directive: ChatUiDirective.text());
  }
}
