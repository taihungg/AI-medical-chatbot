import 'package:flutter/material.dart';
import '../state/chat_directive.dart';
import 'glass_widgets.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Interactive chat components.
///
/// Each widget renders one [ChatUiDirective] type inside the chat. They are
/// dumb views: given a directive + an [enabled] flag, they call back with the
/// user's choice. The chat screen forwards that to AppState.respondToDirective.
/// Once answered, [enabled] is false and the component renders read-only.
/// ─────────────────────────────────────────────────────────────────────────

typedef OnOptionPicked = void Function(ChatOption option);
typedef OnOptionsConfirmed = void Function(List<ChatOption> options);
typedef OnSliderSubmitted = void Function(double value);
typedef OnReportBook = void Function();

/// Dispatch entry point: directive → widget.
class ChatDirectiveView extends StatelessWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnOptionPicked onPicked;
  final OnOptionsConfirmed onConfirmed;
  final OnSliderSubmitted onSlider;
  final OnReportBook onBook;

  const ChatDirectiveView({
    super.key,
    required this.directive,
    required this.enabled,
    required this.onPicked,
    required this.onConfirmed,
    required this.onSlider,
    required this.onBook,
  });

  @override
  Widget build(BuildContext context) {
    switch (directive.type) {
      case ChatComponentType.none:
        return const SizedBox.shrink();
      case ChatComponentType.quickPickChips:
        return _ChipsPicker(
            directive: directive, enabled: enabled, onPicked: onPicked);
      case ChatComponentType.bodyPartPicker:
        return _BodyPartPicker(
            directive: directive, enabled: enabled, onPicked: onPicked);
      case ChatComponentType.multiSelectChips:
        return _MultiSelectChips(
            directive: directive, enabled: enabled, onConfirmed: onConfirmed);
      case ChatComponentType.severitySlider:
        return _SeveritySlider(
            directive: directive, enabled: enabled, onSlider: onSlider);
      case ChatComponentType.timeRangePicker:
        return _TimeRangePicker(
            directive: directive, enabled: enabled, onPicked: onPicked);
      case ChatComponentType.yesNo:
        return _YesNoButtons(
            directive: directive, enabled: enabled, onPicked: onPicked);
      case ChatComponentType.reportSummary:
        return _ReportSummaryCard(report: directive.report!, onBook: onBook);
    }
  }
}

/// Shared wrapper: a faint card behind a component, dimmed once answered.
class _DirectiveShell extends StatelessWidget {
  final String? prompt;
  final bool enabled;
  final Widget child;
  const _DirectiveShell(
      {this.prompt, required this.enabled, required this.child});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.55,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 4, left: 40, right: 4),
        child: GlassCard(
          opacity: 0.5,
          borderColor: GlassTheme.cyan.withValues(alpha: 0.35),
          borderWidth: 1,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (prompt != null) ...[
                Text(
                  prompt!,
                  style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)
                      .copyWith(fontSize: 10),
                ),
                const SizedBox(height: 10),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ── 1. quick-pick chips (single select) ─────────────────────────────────────
class _ChipsPicker extends StatelessWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnOptionPicked onPicked;
  const _ChipsPicker(
      {required this.directive, required this.enabled, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return _DirectiveShell(
      prompt: directive.prompt,
      enabled: enabled,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: directive.options.map((opt) {
          return ActionChip(
            backgroundColor: Colors.white.withValues(alpha: 0.6),
            side:
                BorderSide(color: GlassTheme.oceanBlue.withValues(alpha: 0.35)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            avatar: opt.icon != null
                ? Icon(opt.icon, size: 16, color: GlassTheme.oceanBlue)
                : null,
            label: Text(opt.label,
                style: GlassTheme.bodyMd().copyWith(fontSize: 13)),
            onPressed: enabled ? () => onPicked(opt) : null,
          );
        }).toList(),
      ),
    );
  }
}

// ── 2. body-part picker (single select, larger tiles) ───────────────────────
class _BodyPartPicker extends StatelessWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnOptionPicked onPicked;
  const _BodyPartPicker(
      {required this.directive, required this.enabled, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return _DirectiveShell(
      prompt: directive.prompt,
      enabled: enabled,
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: directive.options.map((opt) {
          return InkWell(
            onTap: enabled ? () => onPicked(opt) : null,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 92,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: GlassTheme.oceanBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  Icon(opt.icon ?? Icons.accessibility_new,
                      color: GlassTheme.oceanBlue, size: 26),
                  const SizedBox(height: 6),
                  Text(
                    opt.label,
                    style: GlassTheme.bodyMd().copyWith(fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── 3. multi-select chips + confirm ─────────────────────────────────────────
class _MultiSelectChips extends StatefulWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnOptionsConfirmed onConfirmed;
  const _MultiSelectChips(
      {required this.directive,
      required this.enabled,
      required this.onConfirmed});

  @override
  State<_MultiSelectChips> createState() => _MultiSelectChipsState();
}

class _MultiSelectChipsState extends State<_MultiSelectChips> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return _DirectiveShell(
      prompt: widget.directive.prompt,
      enabled: widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.directive.options.map((opt) {
              final isSel = _selected.contains(opt.value);
              return FilterChip(
                selected: isSel,
                showCheckmark: true,
                checkmarkColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.6),
                selectedColor: GlassTheme.oceanBlue,
                side: BorderSide(
                    color: GlassTheme.oceanBlue.withValues(alpha: 0.35)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                avatar: opt.icon != null && !isSel
                    ? Icon(opt.icon, size: 16, color: GlassTheme.oceanBlue)
                    : null,
                label: Text(
                  opt.label,
                  style: GlassTheme.bodyMd(
                          color: isSel ? Colors.white : GlassTheme.onSurface)
                      .copyWith(fontSize: 13),
                ),
                onSelected: widget.enabled
                    ? (v) => setState(() => v
                        ? _selected.add(opt.value)
                        : _selected.remove(opt.value))
                    : null,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GlassButton(
            text: _selected.isEmpty
                ? "Bỏ qua / Không có"
                : "Xác nhận (${_selected.length})",
            height: 42,
            onPressed: widget.enabled
                ? () {
                    final picks = widget.directive.options
                        .where((o) => _selected.contains(o.value))
                        .toList();
                    widget.onConfirmed(picks);
                  }
                : () {},
          ),
        ],
      ),
    );
  }
}

// ── 4. severity slider ──────────────────────────────────────────────────────
class _SeveritySlider extends StatefulWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnSliderSubmitted onSlider;
  const _SeveritySlider(
      {required this.directive, required this.enabled, required this.onSlider});

  @override
  State<_SeveritySlider> createState() => _SeveritySliderState();
}

class _SeveritySliderState extends State<_SeveritySlider> {
  late double _value;

  @override
  void initState() {
    super.initState();
    final spec = widget.directive.slider ?? const SliderSpec();
    _value = (spec.min + spec.max) / 2;
  }

  Color _color() => _value >= 7
      ? GlassTheme.error
      : (_value >= 4 ? Colors.orange : Colors.green);

  @override
  Widget build(BuildContext context) {
    final spec = widget.directive.slider ?? const SliderSpec();
    return _DirectiveShell(
      prompt: widget.directive.prompt,
      enabled: widget.enabled,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "${_value.toInt()}${spec.unitSuffix}",
                style: GlassTheme.h1(color: _color()).copyWith(fontSize: 32),
              ),
            ],
          ),
          Slider(
            value: _value,
            min: spec.min,
            max: spec.max,
            divisions: spec.divisions,
            activeColor: _color(),
            inactiveColor: Colors.white38,
            label: "${_value.toInt()}",
            onChanged:
                widget.enabled ? (v) => setState(() => _value = v) : null,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(spec.minLabel,
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                      .copyWith(fontSize: 11)),
              Text(spec.maxLabel,
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                      .copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 12),
          GlassButton(
            text: "Gửi đánh giá",
            height: 42,
            onPressed: widget.enabled ? () => widget.onSlider(_value) : () {},
          ),
        ],
      ),
    );
  }
}

// ── 5. time-range picker ────────────────────────────────────────────────────
class _TimeRangePicker extends StatelessWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnOptionPicked onPicked;
  const _TimeRangePicker(
      {required this.directive, required this.enabled, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    return _DirectiveShell(
      prompt: directive.prompt,
      enabled: enabled,
      child: Row(
        children: directive.timeRanges.map((opt) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.4),
                  side: BorderSide(
                      color: GlassTheme.oceanBlue.withValues(alpha: 0.4)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: enabled ? () => onPicked(opt) : null,
                child: Column(
                  children: [
                    if (opt.icon != null)
                      Icon(opt.icon, size: 16, color: GlassTheme.oceanBlue),
                    const SizedBox(height: 4),
                    Text(
                      opt.label,
                      style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue)
                          .copyWith(fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── 6. yes / no buttons ─────────────────────────────────────────────────────
class _YesNoButtons extends StatelessWidget {
  final ChatUiDirective directive;
  final bool enabled;
  final OnOptionPicked onPicked;
  const _YesNoButtons(
      {required this.directive, required this.enabled, required this.onPicked});

  @override
  Widget build(BuildContext context) {
    final opts = directive.options;
    return _DirectiveShell(
      prompt: directive.prompt,
      enabled: enabled,
      child: Row(
        children: [
          for (int i = 0; i < opts.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(
              child: GlassButton(
                text: opts[i].label,
                icon: opts[i].icon,
                isPrimary: opts[i].value == 'yes',
                height: 46,
                onPressed: enabled ? () => onPicked(opts[i]) : () {},
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 7. structured report card + booking CTA ─────────────────────────────────
class _ReportSummaryCard extends StatelessWidget {
  final ReportData report;
  final OnReportBook onBook;
  const _ReportSummaryCard({required this.report, required this.onBook});

  Color _riskColor() {
    switch (report.riskLevel) {
      case "Khẩn cấp":
        return GlassTheme.error;
      case "Cao":
        return Colors.orange[800]!;
      case "Trung bình":
        return GlassTheme.oceanBlue;
      default:
        return Colors.green[700]!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final risk = _riskColor();
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 4, left: 40, right: 4),
      child: GlassCard(
        borderColor: GlassTheme.cyan,
        borderWidth: 1.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: GlassTheme.cyan.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_outlined,
                      color: GlassTheme.oceanBlue, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Báo Cáo Tổng Hợp AI",
                    style: GlassTheme.h3(color: GlassTheme.oceanBlue)
                        .copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: risk.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: risk.withValues(alpha: 0.3)),
                  ),
                  child: Text(report.riskLevel,
                      style: GlassTheme.labelCaps(color: risk)
                          .copyWith(fontSize: 10)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _reportRow("Triệu chứng chính", report.chiefComplaint),
            if (report.associated.isNotEmpty)
              _reportRow("Triệu chứng kèm theo", report.associated.join(", ")),
            if (report.severity > 0)
              _reportRow("Mức độ", "${report.severity}/10"),
            if (report.duration.isNotEmpty)
              _reportRow("Thời gian", report.duration),
            if (report.suggestedSpecialty.isNotEmpty)
              _reportRow("Chuyên khoa gợi ý", report.suggestedSpecialty),
            const SizedBox(height: 12),
            const Divider(color: Colors.white38),
            const SizedBox(height: 8),
            Text(
              report.recommendation,
              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                  .copyWith(height: 1.4),
            ),
            const SizedBox(height: 16),
            GlassButton(
              text: "Đặt lịch khám ngay",
              icon: Icons.edit_calendar,
              onPressed: onBook,
            ),
          ],
        ),
      ),
    );
  }

  Widget _reportRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)
                    .copyWith(fontSize: 10)),
          ),
          Expanded(
            child: Text(value,
                style:
                    GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
