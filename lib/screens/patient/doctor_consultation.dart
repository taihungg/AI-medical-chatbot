import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../doctor/recording_visualizer.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final AppAppointment appointment;

  const DoctorConsultationScreen({super.key, required this.appointment});

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  int _callDurationSeconds = 0;
  Timer? _timer;
  bool _isMicMuted = false;
  bool _isCameraOff = false;
  bool _isRecordingAI = false;



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


  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _toggleAIDictation() {
    setState(() {
      _isRecordingAI = !_isRecordingAI;
    });
    
    // Khi tắt AI → sinh mock transcript và lưu vào AppState
    if (!_isRecordingAI) {
      final appt = widget.appointment;
      final sym = appt.symptomSummary.toLowerCase();
      String s, o, a, p;
      
      if (sym.contains("ho") || sym.contains("phổi") || sym.contains("sốt")) {
        s = "Ho khan từng cơn kéo dài, sốt nhẹ 37.5 về chiều.";
        o = "Ran phế quản nhẹ phổi trái, SpO2: 97%.";
        a = "Viêm phế quản cấp, cần X-quang phổi.";
        p = "Amoxicillin 500mg, siro ho. Tái khám 5 ngày.";
      } else if (sym.contains("đầu") || sym.contains("chóng mặt")) {
        s = "Đau nửa đầu dữ dội kèm buồn nôn, sợ ánh sáng.";
        o = "Tri giác tỉnh, pupil đều, HA 130/85.";
        a = "Migraine không aura, tần suất cao.";
        p = "Nghỉ ngơi, Sumatriptan 50mg khi đau.";
      } else {
        s = "Đau tức ngực trái khi gắng sức, lan ra vai trái.";
        o = "HA 140/92, nhịp tim 88 bpm, SpO2 95%.";
        a = "Nghi ngờ bệnh mạch vành, cần ECG.";
        p = "ECG khẩn, phác đồ kiểm soát mạch.";
      }
      
      final notes = "S: $s\nO: $o\nA: $a\nP: $p";
      AppState.instance.saveConsultationNotes(appt.id, notes, []);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Ghi chú AI đã được lưu vào hồ sơ lâm sàng."),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getCallDurationString() {
    final min = (_callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_callDurationSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }



  void _endConsultation() {
    final appState = AppState.instance;
    
    // Revert status nếu chưa ban hành (Đang khám → Chưa khám)
    if (widget.appointment.status == 'Đang khám') {
      appState.stopExamination(widget.appointment.id);
    }
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
                          color: GlassTheme.oceanBlue.withValues(alpha: 0.35),
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
                            color: GlassTheme.cyan.withValues(alpha: 0.3),
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
                      child: Center(
                        child: Icon(
                          _isCameraOff ? Icons.videocam_off : Icons.person,
                          color: Colors.white30, 
                          size: 28
                        ),
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

          // 4. AI DICTATION OVERLAY
          Positioned(
            bottom: 120,
            left: 20,
            right: 20,
            child: Center(
              child: _isRecordingAI
                  ? const SizedBox(
                      width: 320,
                      child: RecordingVisualizer(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // 5. CALL CONTROL DOCK
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Mic trigger
                _buildCircleActionButton(
                  _isMicMuted ? Icons.mic_off : Icons.mic,
                  _isMicMuted ? Colors.red.withValues(alpha: 0.8) : Colors.white24,
                  () {
                    setState(() {
                      _isMicMuted = !_isMicMuted;
                    });
                  }
                ),
                
                // AI Dictation trigger
                _buildCircleActionButton(
                  Icons.auto_awesome,
                  _isRecordingAI ? Colors.pinkAccent : Colors.white24,
                  _toggleAIDictation,
                ),
                
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
                _buildCircleActionButton(
                  _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  _isCameraOff ? Colors.red.withOpacity(0.8) : Colors.white24,
                  () {
                    setState(() {
                      _isCameraOff = !_isCameraOff;
                    });
                  }
                ),
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
