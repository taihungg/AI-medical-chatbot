import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';

class DoctorConsultationScreen extends StatelessWidget {
  final AppAppointment appointment;

  const DoctorConsultationScreen({
    super.key,
    required this.appointment,
  });

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
                              appointment.doctorName,
                              style: GlassTheme.h2(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              appointment.specialty,
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
                                  "${appointment.patientName} • ${appointment.timeSlot}",
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
              GlassCard(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallAction(icon: Icons.mic, label: "Mic"),
                    _CallAction(icon: Icons.videocam, label: "Camera"),
                    _CallAction(icon: Icons.screen_share, label: "Chia sẻ"),
                    _CallAction(
                      icon: Icons.call_end,
                      label: "Kết thúc",
                      color: GlassTheme.error,
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
                      appointment.symptomSummary,
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
  final Color color;
  final VoidCallback? onTap;

  const _CallAction({
    required this.icon,
    required this.label,
    this.color = GlassTheme.oceanBlue,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: GlassTheme.labelCaps(color: color).copyWith(fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }
}
