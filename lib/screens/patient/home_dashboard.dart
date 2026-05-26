import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import 'symptom_flow.dart';
import 'appointment_booking.dart';
import 'medication_catalog.dart';
import 'doctor_consultation.dart';

class PatientHomeDashboard extends StatelessWidget {
  const PatientHomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        // Filter appointments that are not completed yet
        final activeAppts = appState.appointments
            .where((appt) => appt.status != 'Hoàn thành')
            .toList();

        return Scaffold(
          body: GlassBackground(
            child: RefreshIndicator(
              onRefresh: () async {
                // Pull data simulation
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                children: [
                  const SizedBox(height: 12),
                  // User Profile Top Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Xin chào,",
                            style: GlassTheme.bodyLg(color: GlassTheme.onSurfaceVariant),
                          ),
                          Text(
                            appState.currentRole == UserRole.seeker ? "Khách tư vấn nhanh" : "Nguyễn Minh Anh",
                            style: GlassTheme.h1(color: GlassTheme.oceanBlue).copyWith(fontSize: 24),
                          ),
                        ],
                      ),
                      // Verified Patient avatar or badge
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                          gradient: GlassTheme.accentGradient,
                        ),
                        child: const Center(
                          child: Icon(Icons.person_pin, color: Colors.white, size: 28),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Health Status Bento Card
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: GlassTheme.oceanBlue.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.shield, color: GlassTheme.oceanBlue, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "Chỉ Số Sức Khỏe Tổng Quan",
                              style: GlassTheme.h3(color: GlassTheme.oceanBlue).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildMiniMetric("Huyết áp", "120/80", "mmHg", Colors.green),
                            _buildMiniMetric("Nhịp tim", "78", "bpm", Colors.pink),
                            _buildMiniMetric("Nhiệt độ", "36.8", "°C", Colors.orange),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick Action Section
                  Text(
                    "Dịch Vụ Y Tế AI",
                    style: GlassTheme.h2(color: GlassTheme.oceanBlue).copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  GridVisualSelector(
                    onAIAssess: () {
                      // Navigate to AI Chatbot Assessment (Page Index 1 in shell is AI assessment)
                      // Or directly push the assessment flow wizard
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SymptomFlowScreen()),
                      );
                    },
                    onBook: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AppointmentBookingScreen()),
                      );
                    },
                    onPharma: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const MedicationCatalogScreen()),
                      );
                    },
                    onConsult: () {
                      if (activeAppts.isNotEmpty) {
                        final targetAppt = activeAppts.first;
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DoctorConsultationScreen(appointment: targetAppt)),
                        );
                      } else {
                        // Directly trigger quick doctor call simulation
                        final simulatedAppt = AppAppointment(
                          id: "APT-QUICK",
                          patientName: "Nguyễn Minh Anh",
                          branchName: "Chi nhánh Trực tuyến",
                          doctorName: "BS. Nguyễn Văn An",
                          specialty: "Khoa Nội tổng hợp",
                          dateTime: DateTime.now(),
                          timeSlot: "Bây giờ",
                          symptomSummary: "Yêu cầu tư vấn nhanh qua video trực tuyến",
                          riskLevel: "Trung bình",
                          status: "Đang khám",
                        );
                        appState.setActiveConsultation(simulatedAppt);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => DoctorConsultationScreen(appointment: simulatedAppt)),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 28),

                  // Upcoming Appointments Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Lịch Hẹn Sắp Tới",
                        style: GlassTheme.h2(color: GlassTheme.oceanBlue).copyWith(fontSize: 18),
                      ),
                      if (activeAppts.length > 1)
                        Text(
                          "Xem tất cả (${activeAppts.length})",
                          style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue).copyWith(fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (activeAppts.isEmpty)
                    GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 40, color: GlassTheme.outline.withOpacity(0.6)),
                            const SizedBox(height: 12),
                            Text(
                              "Bạn chưa có lịch hẹn nào sắp tới.",
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            GlassButton(
                              text: "Đặt lịch ngay",
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => const AppointmentBookingScreen()),
                                );
                              },
                              height: 44,
                              width: 160,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ...activeAppts.map((appt) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: GlassTheme.oceanBlue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    appt.specialty,
                                    style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: appt.status == 'Đang khám'
                                        ? Colors.green.withOpacity(0.15)
                                        : Colors.amber.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    appt.status,
                                    style: GlassTheme.labelCaps(
                                      color: appt.status == 'Đang khám' ? Colors.green : Colors.amber[800]!,
                                    ).copyWith(fontSize: 10),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              appt.doctorName,
                              style: GlassTheme.h3(),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              appt.branchName,
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            const Divider(color: Colors.white30),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 16, color: GlassTheme.oceanBlue),
                                    const SizedBox(width: 8),
                                    Text(
                                      "${appt.dateTime.day}/${appt.dateTime.month} - ${appt.timeSlot}",
                                      style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                                // Action CTA based on status
                                if (appt.status == 'Đang khám' || appt.id == "APT-8801")
                                  TextButton.icon(
                                    onPressed: () {
                                      // Start consultation loop
                                      appState.setActiveConsultation(appt);
                                      appt.status = 'Đang khám';
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => DoctorConsultationScreen(appointment: appt),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.video_call, color: Colors.green),
                                    label: Text(
                                      "Vào phòng khám",
                                      style: GlassTheme.labelCaps(color: Colors.green),
                                    ),
                                  )
                                else
                                  Text(
                                    appt.id,
                                    style: GlassTheme.labelCaps(color: GlassTheme.outline),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    )),

                  const SizedBox(height: 80), // Prevent cover by navigation floating dock
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMiniMetric(String label, String value, String unit, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: GlassTheme.h2(color: color).copyWith(fontSize: 20),
            ),
            const SizedBox(width: 2),
            Text(
              unit,
              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}

// Custom Grid Selector for Patient Home Actions
class GridVisualSelector extends StatelessWidget {
  final VoidCallback onAIAssess;
  final VoidCallback onBook;
  final VoidCallback onPharma;
  final VoidCallback onConsult;

  const GridVisualSelector({
    super.key,
    required this.onAIAssess,
    required this.onBook,
    required this.onPharma,
    required this.onConsult,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            // Chat AI
            Expanded(
              child: GestureDetector(
                onTap: onAIAssess,
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.only(right: 8, bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: GlassTheme.cyan,
                    borderWidth: 1.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: GlassTheme.cyan.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.chat_bubble_rounded, color: GlassTheme.oceanBlue, size: 24),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Khám Triệu Chứng AI",
                              style: GlassTheme.h3().copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Đánh giá nguy cơ tức thì",
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Book Appointment
            Expanded(
              child: GestureDetector(
                onTap: onBook,
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.only(left: 8, bottom: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit_calendar, color: Colors.amber, size: 24),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Đặt Lịch Phòng Khám",
                              style: GlassTheme.h3().copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Chọn cơ sở & bác sĩ",
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            // Online Consultation
            Expanded(
              child: GestureDetector(
                onTap: onConsult,
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.only(right: 8, top: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.video_camera_front, color: Colors.green, size: 24),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tư Vấn Trực Tuyến",
                              style: GlassTheme.h3().copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Video call 24/7 với BS",
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Pharmacy
            Expanded(
              child: GestureDetector(
                onTap: onPharma,
                child: Container(
                  height: 130,
                  margin: const EdgeInsets.only(left: 8, top: 8),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.local_pharmacy, color: Colors.purple, size: 24),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Nhà Thuốc Đã Kê",
                              style: GlassTheme.h3().copyWith(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Tra cứu đơn thuốc",
                              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
