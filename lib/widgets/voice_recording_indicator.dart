import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'glass_widgets.dart';

/// Compact "listening" banner with animated waveform.
class VoiceRecordingIndicator extends StatefulWidget {
  const VoiceRecordingIndicator({super.key});

  @override
  State<VoiceRecordingIndicator> createState() => _VoiceRecordingIndicatorState();
}

class _VoiceRecordingIndicatorState extends State<VoiceRecordingIndicator> {
  double _recordingSeconds = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      setState(() => _recordingSeconds += 0.1);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: GlassTheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: GlassTheme.error.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
            const SizedBox(width: 8),
            Text(
              "Đang nghe giọng nói... ${_recordingSeconds.toStringAsFixed(1)}s",
              style: GlassTheme.labelCaps(color: GlassTheme.error)
                  .copyWith(fontSize: 10),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 16,
                child: CustomPaint(
                  painter: RecordingWavePainter(seconds: _recordingSeconds),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecordingWavePainter extends CustomPainter {
  final double seconds;

  RecordingWavePainter({required this.seconds});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GlassTheme.cyan
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double midY = size.height / 2;
    const int barsCount = 20;
    final double barGap = size.width / (barsCount + 1);

    for (int i = 0; i < barsCount; i++) {
      final double x = (i + 1) * barGap;
      final double waveHeight =
          2.0 + 8.0 * sin(seconds * 5 + i) * cos(seconds * 3 + i * 2).abs();
      canvas.drawLine(
        Offset(x, midY - waveHeight),
        Offset(x, midY + waveHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RecordingWavePainter oldDelegate) => true;
}
