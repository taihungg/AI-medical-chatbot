import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Gemini-ready UI directive model.
///
/// Every bot turn produces an optional [ChatUiDirective] describing WHICH
/// interactive component to render in the chat and WHAT data feeds it. The MVP
/// builds these from a scripted decision tree (see conversation_graph.dart);
/// later, Gemini returns the same JSON and we deserialize with [fromJson].
///
/// The chat UI only ever reads these data objects — it has no idea whether the
/// directive came from a script or from Gemini. That is the key seam that lets
/// us swap in the real model without touching the UI.
/// ─────────────────────────────────────────────────────────────────────────

/// The interactive component the bot wants rendered under its message bubble.
enum ChatComponentType {
  none, // plain text bubble, no interactive component
  quickPickChips, // single-select chips ("Đau đầu", "Đau bụng"...)
  multiSelectChips, // multi-select chips + confirm button
  severitySlider, // 1–10 severity slider
  timeRangePicker, // onset / duration buckets
  yesNo, // friendly yes/no buttons (triage, confirmations)
  bodyPartPicker, // body-region picker
  reportSummary, // structured report card + "Đặt lịch" CTA
}

/// Maps a stable icon name (what Gemini emits as a string) to an [IconData].
/// We never serialize raw codepoints — they are not stable across builds.
const Map<String, IconData> kChatIconByName = {
  'head': Icons.psychology_alt,
  'stomach': Icons.sick,
  'heart': Icons.favorite_border,
  'fever': Icons.thermostat,
  'lungs': Icons.air,
  'chest': Icons.monitor_heart,
  'back': Icons.airline_seat_recline_normal,
  'limb': Icons.accessibility_new,
  'dizzy': Icons.blur_on,
  'nausea': Icons.water_drop,
  'light': Icons.light_mode,
  'time': Icons.schedule,
  'check': Icons.check_circle_outline,
  'close': Icons.cancel_outlined,
};

IconData? _iconFromName(String? name) => name == null ? null : kChatIconByName[name];

String? _nameFromIcon(IconData? icon) {
  if (icon == null) return null;
  for (final entry in kChatIconByName.entries) {
    if (entry.value == icon) return entry.key;
  }
  return null;
}

/// A single selectable option (chip / yes-no / body part / time bucket).
///
/// [value] is the stable machine key the decision logic branches on.
/// [nextNodeId] optionally tells the scripted graph which node to advance to
/// when this option is picked — this is how selecting "Đau đầu" produces the
/// next set of headache-specific options.
class ChatOption {
  final String label; // "Đau đầu"  (shown to the user)
  final String value; // "dau_dau"  (stable key)
  final IconData? icon;
  final String? riskHint; // optional precomputed risk e.g. "Khẩn cấp"
  final String? nextNodeId; // optional scripted-graph advance target

  const ChatOption({
    required this.label,
    required this.value,
    this.icon,
    this.riskHint,
    this.nextNodeId,
  });

  factory ChatOption.fromJson(Map<String, dynamic> j) => ChatOption(
        label: j['label'] as String,
        value: j['value'] as String,
        icon: _iconFromName(j['icon'] as String?),
        riskHint: j['riskHint'] as String?,
        nextNodeId: j['nextNodeId'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'label': label,
        'value': value,
        if (_nameFromIcon(icon) != null) 'icon': _nameFromIcon(icon),
        if (riskHint != null) 'riskHint': riskHint,
        if (nextNodeId != null) 'nextNodeId': nextNodeId,
      };
}

/// Configuration for a [ChatComponentType.severitySlider].
class SliderSpec {
  final double min;
  final double max;
  final int divisions;
  final String minLabel;
  final String maxLabel;
  final String unitSuffix;

  const SliderSpec({
    this.min = 1,
    this.max = 10,
    this.divisions = 9,
    this.minLabel = 'Nhẹ nhàng',
    this.maxLabel = 'Rất dữ dội',
    this.unitSuffix = '/10',
  });

  factory SliderSpec.fromJson(Map<String, dynamic> j) => SliderSpec(
        min: (j['min'] as num?)?.toDouble() ?? 1,
        max: (j['max'] as num?)?.toDouble() ?? 10,
        divisions: (j['divisions'] as num?)?.toInt() ?? 9,
        minLabel: j['minLabel'] as String? ?? 'Nhẹ nhàng',
        maxLabel: j['maxLabel'] as String? ?? 'Rất dữ dội',
        unitSuffix: j['unitSuffix'] as String? ?? '/10',
      );

  Map<String, dynamic> toJson() => {
        'min': min,
        'max': max,
        'divisions': divisions,
        'minLabel': minLabel,
        'maxLabel': maxLabel,
        'unitSuffix': unitSuffix,
      };
}

/// Structured medical report compiled from the conversation, rendered as a
/// summary card and used to pre-fill the booking tab.
class ReportData {
  final String chiefComplaint; // "Đau đầu"
  final List<String> associated; // ["Buồn nôn", "Sợ ánh sáng"]
  final int severity; // 0 = not asked
  final String duration; // "Hơn 3 ngày"
  final String riskLevel; // "Thấp" | "Trung bình" | "Cao" | "Khẩn cấp"
  final String recommendation; // friendly advice line
  final String suggestedSpecialty; // "Khoa Thần kinh"

  const ReportData({
    required this.chiefComplaint,
    this.associated = const [],
    this.severity = 0,
    this.duration = '',
    required this.riskLevel,
    this.recommendation = '',
    this.suggestedSpecialty = '',
  });

  /// The exact string stored in [AppState.selectedSymptomsText] for booking
  /// prefill. Keeps the Vietnamese keyword from [chiefComplaint] so the booking
  /// tab's specialty auto-routing (which scans for "đầu", "ngực", "ho"...) still
  /// works.
  String toBookingSummaryString() {
    final buf = StringBuffer();
    buf.write('Triệu chứng chính: $chiefComplaint.');
    if (associated.isNotEmpty) {
      buf.write(' Kèm theo: ${associated.join(", ")}.');
    }
    if (severity > 0) buf.write(' Mức độ: $severity/10.');
    if (duration.isNotEmpty) buf.write(' Thời gian: $duration.');
    return buf.toString();
  }

  factory ReportData.fromJson(Map<String, dynamic> j) => ReportData(
        chiefComplaint: j['chiefComplaint'] as String? ?? '',
        associated: (j['associated'] as List?)?.map((e) => e.toString()).toList() ?? const [],
        severity: (j['severity'] as num?)?.toInt() ?? 0,
        duration: j['duration'] as String? ?? '',
        riskLevel: j['riskLevel'] as String? ?? 'Trung bình',
        recommendation: j['recommendation'] as String? ?? '',
        suggestedSpecialty: j['suggestedSpecialty'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'chiefComplaint': chiefComplaint,
        'associated': associated,
        'severity': severity,
        'duration': duration,
        'riskLevel': riskLevel,
        'recommendation': recommendation,
        'suggestedSpecialty': suggestedSpecialty,
      };
}

/// The full directive attached to a bot message.
class ChatUiDirective {
  final ChatComponentType type;
  final String? prompt; // optional sub-label above the component
  final List<ChatOption> options; // chips / yesNo / bodyPart entries
  final SliderSpec? slider;
  final List<ChatOption> timeRanges;
  final ReportData? report;
  final bool allowFreeText; // free text is always allowed; this is a UI hint
  final String directiveId; // correlates a user's response back to this directive

  const ChatUiDirective({
    required this.type,
    this.prompt,
    this.options = const [],
    this.slider,
    this.timeRanges = const [],
    this.report,
    this.allowFreeText = true,
    this.directiveId = '',
  });

  /// A plain text bubble with no interactive component.
  factory ChatUiDirective.text() => const ChatUiDirective(type: ChatComponentType.none);

  bool get isInteractive => type != ChatComponentType.none;

  factory ChatUiDirective.fromJson(Map<String, dynamic> j) => ChatUiDirective(
        type: ChatComponentType.values.firstWhere(
          (t) => t.name == j['type'],
          orElse: () => ChatComponentType.none,
        ),
        prompt: j['prompt'] as String?,
        options: (j['options'] as List?)
                ?.map((e) => ChatOption.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        slider: j['slider'] == null ? null : SliderSpec.fromJson(j['slider'] as Map<String, dynamic>),
        timeRanges: (j['timeRanges'] as List?)
                ?.map((e) => ChatOption.fromJson(e as Map<String, dynamic>))
                .toList() ??
            const [],
        report: j['report'] == null ? null : ReportData.fromJson(j['report'] as Map<String, dynamic>),
        allowFreeText: j['allowFreeText'] as bool? ?? true,
        directiveId: j['directiveId'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        if (prompt != null) 'prompt': prompt,
        if (options.isNotEmpty) 'options': options.map((o) => o.toJson()).toList(),
        if (slider != null) 'slider': slider!.toJson(),
        if (timeRanges.isNotEmpty) 'timeRanges': timeRanges.map((o) => o.toJson()).toList(),
        if (report != null) 'report': report!.toJson(),
        'allowFreeText': allowFreeText,
        'directiveId': directiveId,
      };
}

/// What the seam ([AppState] `_generateBotReply`) returns for one bot turn.
/// Side effects are declared here (rather than mutated directly) so the seam
/// stays a pure function of conversation state and is trivially swappable.
class BotReply {
  final String text;
  final ChatUiDirective? directive;
  final String? setSymptomsText; // structured report string for booking prefill
  final String? setRiskLevel; // 'Thấp' | 'Trung bình' | 'Cao' | 'Khẩn cấp'
  final bool triggerBooking; // fire AppState.triggerBookingFromAI()
  final bool triggerEmergencySos; // route to the SOS screen

  const BotReply({
    required this.text,
    this.directive,
    this.setSymptomsText,
    this.setRiskLevel,
    this.triggerBooking = false,
    this.triggerEmergencySos = false,
  });
}

/// Immutable snapshot of conversation state handed to the seam each turn.
/// Gemini will receive essentially this (history + the latest user action).
class ChatTurnContext {
  final String userText; // latest free text ("" for pure component responses)
  final String? directiveId; // which directive is being answered (null = free text)
  final String? selectedValue; // single chip / yesNo / bodyPart / time value
  final List<String>? selectedValues; // multi-select values
  final double? sliderValue; // severity

  const ChatTurnContext({
    this.userText = '',
    this.directiveId,
    this.selectedValue,
    this.selectedValues,
    this.sliderValue,
  });

  bool get isFreeText => directiveId == null;
}
