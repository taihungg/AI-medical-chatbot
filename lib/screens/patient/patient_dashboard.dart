import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class PatientDashboardScreen extends StatelessWidget {
  const PatientDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppState.instance;
    final name = state.currentUserProfile?.name.split(' ').last ?? "Bệnh nhân";

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: const GlassAppBar(
        title: "Trang chủ",
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Xin chào, $name!",
              style: GlassTheme.h1(color: GlassTheme.primary),
            ),
            const SizedBox(height: 4),
            Text(
              "Hôm nay bạn cảm thấy thế nào?",
              style: GlassTheme.bodyLg(color: GlassTheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),

            // Quick Actions (Bento grid style)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => AppState.instance.setPatientNavIndex(1),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: GlassTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: GlassTheme.oceanBlue.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.smart_toy_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text("Tư vấn", style: GlassTheme.h3(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            "Chẩn đoán triệu chứng tức thì",
                            style: GlassTheme.bodyMd(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => AppState.instance.setPatientNavIndex(2),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0072FF).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.calendar_month_rounded, color: Colors.white, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text("Đặt lịch", style: GlassTheme.h3(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(
                            "Đặt hẹn khám trực tiếp với bác sĩ",
                            style: GlassTheme.bodyMd(color: Colors.white.withOpacity(0.9)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
            Text(
              "Lịch hẹn sắp tới",
              style: GlassTheme.h2(),
            ),
            const SizedBox(height: 12),
            _buildUpcomingAppointments(context, state),

            const SizedBox(height: 32),
            Text(
              "Về DrAI Clinic",
              style: GlassTheme.h2(),
            ),
            const SizedBox(height: 12),
            _buildClinicIntro(),
            const SizedBox(height: 100), // Space for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingAppointments(BuildContext context, AppState state) {
    // List upcoming appointments
    final upcoming = state.appointments.where((a) => a.patientName == (state.currentUserProfile?.name ?? '') && a.status == 'Chưa khám').toList();
    if (upcoming.isEmpty) {
      return GlassCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Icon(Icons.event_available, color: GlassTheme.outline, size: 48),
                const SizedBox(height: 12),
                Text("Bạn không có lịch hẹn nào sắp tới", style: GlassTheme.bodyLg(color: GlassTheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                GlassButton(text: "Đặt lịch ngay", onPressed: () => AppState.instance.setPatientNavIndex(2), isPrimary: false, height: 44, width: 150),
              ],
            ),
          ),
        ),
      );
    }

    final appt = upcoming.first; // Just show the nearest one for dashboard
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: GlassTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text("${appt.dateTime.day}", style: GlassTheme.h1(color: GlassTheme.primary)),
                Text("Thg ${appt.dateTime.month}", style: GlassTheme.labelCaps(color: GlassTheme.primary)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Khám ${appt.specialty}", style: GlassTheme.h3()),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: GlassTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(appt.timeSlot, style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: GlassTheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(appt.branchName, style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicIntro() {
    return GlassCard(
      padding: const EdgeInsets.all(0),
      borderRadius: 24.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
            child: Image.network(
              'https://images.unsplash.com/photo-1519494026892-80bbd2d6fd0d?auto=format&fit=crop&w=800&q=80',
              height: 160,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 160,
                color: GlassTheme.oceanBlue.withOpacity(0.2),
                child: const Icon(Icons.local_hospital, size: 64, color: GlassTheme.oceanBlue),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Hệ thống phòng khám AI tiên tiến", style: GlassTheme.h3()),
                const SizedBox(height: 8),
                Text(
                  "Ứng dụng công nghệ trí tuệ nhân tạo Gemini để hỗ trợ chẩn đoán chính xác và tư vấn sức khỏe 24/7. Với đội ngũ y bác sĩ hàng đầu tại Hà Nội.",
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text("Các chi nhánh tại Hà Nội:", style: GlassTheme.labelCaps(color: GlassTheme.primary)),
                const SizedBox(height: 8),
                _buildBranchRow("DrAI Clinic - Hoàn Kiếm", "Số 1 Tràng Tiền, Q. Hoàn Kiếm"),
                const SizedBox(height: 8),
                _buildBranchRow("DrAI Clinic - Cầu Giấy", "Số 10 Xuân Thủy, Q. Cầu Giấy"),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBranchRow(String name, String address) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_city, size: 18, color: GlassTheme.cyan),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold)),
              Text(address, style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)),
            ],
          ),
        ),
      ],
    );
  }
}
