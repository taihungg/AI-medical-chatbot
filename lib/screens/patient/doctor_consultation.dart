import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final AppAppointment appointment;

  const DoctorConsultationScreen({super.key, required this.appointment});

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  int _callDurationSeconds = 0;
  Timer? _timer;
  final TextEditingController _msgController = TextEditingController();
  final List<String> _inCallMessages = [
    "Xin chào! Tôi là BS. An. Tôi đang xem hồ sơ khảo sát triệu chứng của bạn.",
    "Bạn thấy tức ngực nhiều khi gắng sức hay cả khi nghỉ ngơi?"
  ];

  // Animated wave points for ECG heart monitor simulation
  final List<double> _wavePoints = [];
  Timer? _waveTimer;
  double _wavePhase = 0.0;

  @override
  void initState() {
    super.initState();
    // Start stopwatch
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });

    // Start fluctuating AppState vitals simulation
    AppState.instance.startVitalsSimulation();

    // Initialize ECG wave points
    for (int i = 0; i < 40; i++) {
      _wavePoints.add(0.0);
    }
    
    // Wave animation timer
    _waveTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!mounted) return;
      setState(() {
        _wavePhase += 0.4;
        _wavePoints.removeAt(0);
        // Generate ECG styled beats
        double val = sin(_wavePhase);
        // Add random heart beats spikes
        if (Random().nextDouble() > 0.88) {
          val = 2.5 * (Random().nextDouble() > 0.5 ? 1 : -1);
        } else if (Random().nextDouble() > 0.95) {
          val = 0.0;
        } else {
          val = val * 0.25; // damp normal waves
        }
        _wavePoints.add(val);
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _waveTimer?.cancel();
    _msgController.dispose();
    super.dispose();
  }

  String _getCallDurationString() {
    final min = (_callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_callDurationSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  void _sendInCallMessage() {
    if (_msgController.text.trim().isEmpty) return;
    setState(() {
      _inCallMessages.add(_msgController.text);
      _msgController.clear();
    });
  }

  void _endConsultation() {
    final appState = AppState.instance;
    
    // Update appointment status to complete if doctor signed, otherwise let it sit
    appState.addAuditLog("Phiên khám video của bệnh nhân ${widget.appointment.patientName} kết thúc.");
    
    // Conclude screen and pop
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          borderColor: GlassTheme.oceanBlue,
          borderWidth: 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 56),
              const SizedBox(height: 16),
              Text(
                "Kết Thúc Phiên Khám",
                style: GlassTheme.h2(color: GlassTheme.oceanBlue),
              ),
              const SizedBox(height: 12),
              Text(
                "Cuộc gọi tư vấn đã hoàn tất. Bạn có thể tra cứu chuẩn đoán và đơn thuốc đã ký trong thẻ lịch sử hoặc nhà thuốc.",
                style: GlassTheme.bodyMd(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                text: "Quay lại trang chủ",
                onPressed: () {
                  Navigator.of(ctx).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop consultation call
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      body: Stack(
        children: [
          // 1. FULLSCREEN SIMULATED DOCTOR CAMERA FEED
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glowing circular blur backdrops for medical feel
                Positioned(
                  top: 100,
                  child: Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: GlassTheme.oceanBlue.withOpacity(0.35),
                          blurRadius: 90,
                          spreadRadius: 30,
                        ),
                      ],
                    ),
                  ),
                ),
                // Doctor Mock Avatar Placeholder
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: GlassTheme.cyan, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: GlassTheme.cyan.withOpacity(0.3),
                            blurRadius: 30,
                          ),
                        ],
                      ),
                      child: const CircleAvatar(
                        backgroundColor: Colors.white10,
                        child: Icon(Icons.person, color: Colors.white, size: 76),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      widget.appointment.doctorName,
                      style: GlassTheme.h2(color: Colors.white),
                    ),
                    Text(
                      "Đang kết nối hình ảnh HD...",
                      style: GlassTheme.bodyMd(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. PICTURE-IN-PICTURE PATIENT CAMERA FEED (CORNER OVERLAY)
          Positioned(
            top: 60,
            right: 20,
            child: Container(
              width: 100,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30, width: 1.5),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Icon(Icons.videocam_off, color: Colors.white30, size: 28),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Text(
                        "Bạn",
                        style: GlassTheme.labelCaps(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. TIMER & CALL HEADER
          Positioned(
            top: 60,
            left: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "TRỰC TUYẾN • ${_getCallDurationString()}",
                    style: GlassTheme.labelCaps(color: Colors.white).copyWith(fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          // 4. FLOATING DYNAMIC VITALS TELEMETRY DECK
          Positioned(
            bottom: 240,
            left: 20,
            right: 20,
            child: ListenableBuilder(
              listenable: appState,
              builder: (context, child) {
                // Fetch vitals from appointment (simulated to fluctuate in background)
                final pulse = appState.appointments.firstWhere((a) => a.id == widget.appointment.id, orElse: () => widget.appointment).vitals['pulse']?.toInt() ?? 78;
                final o2 = appState.appointments.firstWhere((a) => a.id == widget.appointment.id, orElse: () => widget.appointment).vitals['spO2']?.toInt() ?? 98;
                
                return GlassCard(
                  opacity: 0.15,
                  borderColor: GlassTheme.cyan,
                  borderWidth: 1.2,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Pulse vital
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.favorite, color: Colors.pink, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("NHỊP TIM", style: GlassTheme.labelCaps(color: Colors.white70).copyWith(fontSize: 8)),
                                Text("$pulse bpm", style: GlassTheme.h3(color: Colors.pink).copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                      
                      // SpO2 Vital
                      Expanded(
                        child: Row(
                          children: [
                            const Icon(Icons.water, color: GlassTheme.cyan, size: 24),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("OXY MÁU (SPO2)", style: GlassTheme.labelCaps(color: Colors.white70).copyWith(fontSize: 8)),
                                Text("$o2%", style: GlassTheme.h3(color: GlassTheme.cyan).copyWith(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),

                      // Animated Oscilloscope custom painter
                      Container(
                        width: 80,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: CustomPaint(
                          painter: _ECGWavePainter(points: _wavePoints),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // 5. FLOATING IN-CALL CHAT OVERLAY
          Positioned(
            bottom: 96,
            left: 20,
            right: 20,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 12)],
              ),
              child: GlassCard(
                opacity: 0.25,
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: _inCallMessages.length,
                        itemBuilder: (ctx, idx) => Padding(
                          padding: const EdgeInsets.only(bottom: 6.0),
                          child: Text(
                            _inCallMessages[idx],
                            style: GlassTheme.bodyMd(color: Colors.white).copyWith(fontSize: 11),
                          ),
                        ),
                      ),
                    ),
                    const Divider(color: Colors.white12, height: 12),
                    // Action entry
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _msgController,
                            style: GlassTheme.bodyMd(color: Colors.white).copyWith(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: "Gửi tin nhắn trong cuộc gọi...",
                              hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) => _sendInCallMessage(),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.send, color: GlassTheme.cyan, size: 18),
                          onPressed: _sendInCallMessage,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 6. CALL CONTROL DOCK
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mic trigger
                _buildCircleActionButton(Icons.mic, Colors.white24, () {}),
                
                // End Call button
                GestureDetector(
                  onTap: _endConsultation,
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: GlassTheme.error,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10)],
                    ),
                    child: const Icon(Icons.call_end, color: Colors.white, size: 30),
                  ),
                ),
                
                // Video toggle trigger
                _buildCircleActionButton(Icons.videocam, Colors.white24, () {}),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleActionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white12),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

// ECG Styled waveform custom painter
class _ECGWavePainter extends CustomPainter {
  final List<double> points;

  _ECGWavePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GlassTheme.cyan
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (points.isEmpty) return;

    final double stepX = size.width / (points.length - 1);
    final double midY = size.height / 2;

    path.moveTo(0, midY - points[0] * (size.height / 6));

    for (int i = 1; i < points.length; i++) {
      path.lineTo(i * stepX, midY - points[i] * (size.height / 6));
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ECGWavePainter oldDelegate) => true;
}
