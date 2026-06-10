import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';

class DoctorConsultationScreen extends StatefulWidget {
  final AppAppointment appointment;

  const DoctorConsultationScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<DoctorConsultationScreen> createState() => _DoctorConsultationScreenState();
}

class _DoctorConsultationScreenState extends State<DoctorConsultationScreen> {
  bool isMicOn = true;
  bool isCamOn = true;
  bool isScreenSharing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: "Tư Vấn Trực Tuyến",
        actions: [
          IconButton(
            icon: const Icon(Icons.call_end, color: GlassTheme.error),
            tooltip: "Kết thúc",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: GlassCard(
                  padding: EdgeInsets.zero,
                  borderRadius: 24,
                  borderColor: Colors.teal,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF053B50),
                              Color(0xFF176B87),
                              Color(0xFF64CCC5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 46,
                              backgroundColor:
                                  Colors.white.withValues(alpha: 0.22),
                              child: const Icon(
                                Icons.medical_services,
                                color: Colors.white,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              widget.appointment.doctorName,
                              style: GlassTheme.h2(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.appointment.specialty,
                              style: GlassTheme.bodyMd(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: 16,
                        right: 16,
                        bottom: 16,
                        child: GlassCard(
                          opacity: 0.35,
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              const Icon(Icons.person, color: Colors.white),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "${widget.appointment.patientName} • ${widget.appointment.timeSlot}",
                                  style: GlassTheme.bodyMd(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Icon(Icons.fiber_manual_record,
                                  color: Colors.redAccent, size: 14),
                              const SizedBox(width: 4),
                              Text(
                                "LIVE",
                                style:
                                    GlassTheme.labelCaps(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: GlassTheme.oceanBlue.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallAction(
                      icon: isMicOn ? Icons.mic_outlined : Icons.mic_off_outlined,
                      label: isMicOn ? "Tắt mic" : "Mở mic",
                      iconColor: isMicOn ? Colors.white : Colors.red,
                      backgroundColor: isMicOn ? Colors.white24 : Colors.red.withValues(alpha: 0.2),
                      onTap: () => setState(() => isMicOn = !isMicOn),
                    ),
                    _CallAction(
                      icon: isCamOn ? Icons.videocam_outlined : Icons.videocam_off_outlined,
                      label: isCamOn ? "Tắt cam" : "Mở cam",
                      iconColor: isCamOn ? Colors.white : Colors.red,
                      backgroundColor: isCamOn ? Colors.white24 : Colors.red.withValues(alpha: 0.2),
                      onTap: () => setState(() => isCamOn = !isCamOn),
                    ),
                    _CallAction(
                      icon: isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
                      label: isScreenSharing ? "Dừng chia sẻ" : "Chia sẻ",
                      iconColor: isScreenSharing ? Colors.greenAccent : Colors.white,
                      backgroundColor: isScreenSharing ? Colors.green.withValues(alpha: 0.2) : Colors.white24,
                      onTap: () => setState(() => isScreenSharing = !isScreenSharing),
                    ),
                    _CallAction(
                      icon: Icons.call_end,
                      label: "Kết thúc",
                      backgroundColor: Colors.red,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              GlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Tóm tắt triệu chứng",
                      style: GlassTheme.h3(color: GlassTheme.oceanBlue),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.appointment.symptomSummary,
                      style:
                          GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CallAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CallAction({
    required this.icon,
    required this.label,
    this.backgroundColor = Colors.white24,
    this.iconColor = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {},
        borderRadius: BorderRadius.circular(24),
        splashColor: Colors.white.withValues(alpha: 0.1),
        highlightColor: Colors.white.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: backgroundColor,
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
