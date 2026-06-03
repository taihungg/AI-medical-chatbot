import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class RecordingVisualizer extends StatefulWidget {
  const RecordingVisualizer({super.key});

  @override
  State<RecordingVisualizer> createState() => _RecordingVisualizerState();
}

class _RecordingVisualizerState extends State<RecordingVisualizer> {
  double _recordingSeconds = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingSeconds += 0.1;
      });
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
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
            const SizedBox(width: 8),
            Text(
              "Đang nghe giọng nói... ${_recordingSeconds.toStringAsFixed(1)}s",
              style: const TextStyle(fontSize: 10, color: Colors.white),
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
