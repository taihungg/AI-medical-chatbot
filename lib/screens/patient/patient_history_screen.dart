import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../splash_screen.dart';

class PatientHistoryScreen extends StatelessWidget {
  const PatientHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final allAppts = appState.appointments;
        final activeAppts =
            allAppts.where((a) => a.status != 'Hoàn thành').toList();
        final pastAppts =
            allAppts.where((a) => a.status == 'Hoàn thành').toList();

        return Scaffold(
          appBar: GlassAppBar(
            title: "Lịch Hẹn Của Tôi",
            actions: [
              IconButton(
                icon: const Icon(Icons.swap_horizontal_circle_outlined,
                    color: GlassTheme.oceanBlue, size: 28),
                tooltip: "Đổi vai trò",
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const SplashScreen()),
                  );
                },
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: GlassBackground(
            child: allAppts.isEmpty
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    children: [
                      // Active appointments section
                      if (activeAppts.isNotEmpty) ...[
                        _buildSectionHeader(
                          icon: Icons.event_available,
                          title: "Lịch Hẹn Sắp Tới",
                          subtitle: "${activeAppts.length} lịch hẹn đang chờ",
                          color: GlassTheme.oceanBlue,
                        ),
                        const SizedBox(height: 12),
                        ...activeAppts.map((appt) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildActiveAppointmentCard(appt),
                            )),
                        const SizedBox(height: 24),
                      ],

                      // Past appointments section
                      _buildSectionHeader(
                        icon: Icons.history,
                        title: "Lịch Sử Khám Bệnh",
                        subtitle: pastAppts.isEmpty
                            ? "Chưa có lịch sử"
                            : "${pastAppts.length} lần khám",
                        color: GlassTheme.teal,
                      ),
                      const SizedBox(height: 12),
                      if (pastAppts.isEmpty)
                        GlassCard(
                          child: Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 32.0),
                              child: Column(
                                children: [
                                  Icon(Icons.inbox_outlined,
                                      size: 48,
                                      color: GlassTheme.onSurfaceVariant
                                          .withValues(alpha: 0.4)),
                                  const SizedBox(height: 12),
                                  Text(
                                    "Chưa có lịch sử khám bệnh",
                                    style: GlassTheme.bodyMd(
                                        color: GlassTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      else
                        ...pastAppts.map((appt) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: _buildPastAppointmentCard(appt),
                            )),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    GlassTheme.oceanBlue.withValues(alpha: 0.15),
                    GlassTheme.cyan.withValues(alpha: 0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(
                Icons.calendar_today_outlined,
                size: 44,
                color: GlassTheme.oceanBlue.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Chưa có lịch hẹn nào",
              style: GlassTheme.h3(color: GlassTheme.onSurface),
            ),
            const SizedBox(height: 8),
            Text(
              "Hãy trò chuyện với AI để được tư vấn\nvà đặt lịch khám khi cần.",
              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: GlassTheme.h3(color: GlassTheme.onSurface)
                    .copyWith(fontSize: 16)),
            Text(subtitle,
                style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                    .copyWith(fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildActiveAppointmentCard(AppAppointment appt) {
    return GlassCard(
      borderColor: GlassTheme.oceanBlue.withValues(alpha: 0.4),
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(
                  appt.status, Colors.amber, Colors.amber.shade800),
              Text(appt.id,
                  style: GlassTheme.labelCaps(color: GlassTheme.outline)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                child: const Icon(Icons.person,
                    color: GlassTheme.oceanBlue, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appt.doctorName,
                        style: GlassTheme.h3().copyWith(fontSize: 15)),
                    Text(
                      "${appt.specialty} • ${appt.branchName}",
                      style:
                          GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                              .copyWith(fontSize: 12),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GlassTheme.oceanBlue.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: GlassTheme.oceanBlue),
                const SizedBox(width: 8),
                Text(
                  "${appt.dateTime.day.toString().padLeft(2, '0')}/${appt.dateTime.month.toString().padLeft(2, '0')}/${appt.dateTime.year}",
                  style:
                      GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time,
                    size: 16, color: GlassTheme.oceanBlue),
                const SizedBox(width: 4),
                Text(
                  appt.timeSlot,
                  style:
                      GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.medical_information_outlined,
                  size: 16, color: _riskColor(appt.riskLevel)),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  appt.symptomSummary,
                  style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                      .copyWith(fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastAppointmentCard(AppAppointment appt) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(appt.status, Colors.green, Colors.green),
              Text(appt.id,
                  style: GlassTheme.labelCaps(color: GlassTheme.outline)),
            ],
          ),
          const SizedBox(height: 12),
          Text(appt.doctorName, style: GlassTheme.h3().copyWith(fontSize: 15)),
          Text(
            "${appt.specialty} • ${appt.branchName}",
            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                .copyWith(fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.calendar_today,
                  size: 14, color: GlassTheme.oceanBlue),
              const SizedBox(width: 6),
              Text(
                "${appt.dateTime.day.toString().padLeft(2, '0')}/${appt.dateTime.month.toString().padLeft(2, '0')}/${appt.dateTime.year} - ${appt.timeSlot}",
                style: GlassTheme.bodyMd()
                    .copyWith(fontWeight: FontWeight.w600, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Triệu chứng: ${appt.symptomSummary}",
            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                .copyWith(fontSize: 13),
          ),
          if (appt.clinicalNotes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: GlassTheme.teal.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border:
                    Border.all(color: GlassTheme.teal.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.description_outlined,
                          size: 16, color: GlassTheme.teal),
                      const SizedBox(width: 6),
                      Text(
                        "Kết luận từ bác sĩ",
                        style: GlassTheme.bodyMd(color: GlassTheme.teal)
                            .copyWith(
                                fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appt.clinicalNotes,
                    style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                        .copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
          if (appt.prescriptionSigned && appt.prescriptionList.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified, size: 16, color: Colors.green),
                  const SizedBox(width: 6),
                  Text(
                    "Đơn thuốc đã ký điện tử (${appt.prescriptionList.length} thuốc)",
                    style: GlassTheme.labelCaps(color: Colors.green),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GlassTheme.labelCaps(color: textColor),
      ),
    );
  }

  Color _riskColor(String risk) {
    switch (risk) {
      case 'Khẩn cấp':
        return GlassTheme.error;
      case 'Cao':
        return Colors.orange;
      case 'Trung bình':
        return GlassTheme.oceanBlue;
      default:
        return GlassTheme.teal;
    }
  }
}
