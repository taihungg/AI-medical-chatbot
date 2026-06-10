import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';
import 'clinical_workspace.dart';
import 'doctor_components.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  String _selectedFilter = 'Tất cả';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final now = DateTime.now();
        final todayAppointments = appState.appointments.where((appt) {
          return appt.dateTime.year == now.year &&
              appt.dateTime.month == now.month &&
              appt.dateTime.day == now.day;
        }).toList();

        // Stats
        final countPending = todayAppointments.where((a) => a.status == 'Chưa khám').length;
        final countExamining = todayAppointments.where((a) => a.status == 'Đang khám').length;
        final countDone = todayAppointments.where((a) => a.status == 'Đã khám').length;
        final countOnline = todayAppointments.where((a) => a.isOnline).length;

        // Filter for the list
        final filteredAppointments = todayAppointments.where((appt) {
          bool statusMatch = true;
          if (_selectedFilter == 'Chưa khám') { statusMatch = ['Chưa khám', 'Chờ duyệt', 'Đã xác nhận'].contains(appt.status); }
          else if (_selectedFilter == 'Đã khám') { statusMatch = appt.status == 'Đã khám'; }
          else if (_selectedFilter == 'Online') { statusMatch = appt.isOnline; }
          else if (_selectedFilter == 'Offline') { statusMatch = !appt.isOnline; }

          bool nameMatch = _searchQuery.isEmpty ||
              appt.patientName.toLowerCase().contains(_searchQuery.toLowerCase());
              
          return statusMatch && nameMatch;
        }).toList();

        filteredAppointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

        // Next appointment (first 'Chưa khám' or 'Đang khám')
        final nextAppt = todayAppointments.firstWhere(
            (a) => a.status == 'Chưa khám' || a.status == 'Đang khám',
            orElse: () => AppAppointment(
                  id: '',
                  patientId: '',
                  patientName: '',
                  doctorId: '',
                  doctorName: '',
                  branchName: '',
                  specialty: '',
                  dateTime: DateTime.now(),
                  timeSlot: '',
                  symptomSummary: '',
                  riskLevel: '',
                  isOnline: false,
                  status: '',
                  aiSummary: '',
                ));

        return Scaffold(
          body: GlassBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.transparent,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                    title: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Xin chào, ${appState.currentUserProfile?.name ?? 'BS'}",
                          style: const TextStyle(
                            color: GlassTheme.oceanBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          "Thứ ${now.weekday + 1}, ${now.day}/${now.month}/${now.year}",
                          style: const TextStyle(
                            color: GlassTheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Bento Stats 2x2
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard("Chờ khám", countPending.toString(), Icons.pending_actions, Colors.orange),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard("Đang khám", countExamining.toString(), Icons.run_circle_outlined, Colors.red),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard("Hoàn thành", countDone.toString(), Icons.check_circle_outline, Colors.green),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard("Trực tuyến", countOnline.toString(), Icons.language, Colors.purple),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Next Appointment
                      if (nextAppt.id.isNotEmpty) ...[
                        Text("Lượt tiếp theo", style: GlassTheme.h3()),
                        const SizedBox(height: 12),
                        GlassCard(
                          borderColor: nextAppt.isOnline ? Colors.purple : Colors.orange,
                          borderWidth: 1.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Icon(nextAppt.isOnline ? Icons.language : Icons.local_hospital,
                                            color: nextAppt.isOnline ? Colors.purple : Colors.orange),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(nextAppt.patientName,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                              overflow: TextOverflow.ellipsis),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  StatusBadge(status: nextAppt.status),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text("${nextAppt.timeSlot} • ${nextAppt.specialty}",
                                  style: const TextStyle(color: GlassTheme.onSurfaceVariant)),
                              if (nextAppt.riskLevel == 'Cao' || nextAppt.riskLevel == 'Khẩn cấp') ...[
                                const SizedBox(height: 8),
                                Text("⚠️ Cảnh báo: ${nextAppt.riskLevel}",
                                    style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                              ],
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                child: GlassButton(
                                  text: "Bắt đầu ngay",
                                  onPressed: () => _openWorkspace(nextAppt.id),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Custom Bar Chart (Mock 7 days)
                      Text("Ca khám 7 ngày qua", style: GlassTheme.h3()),
                      const SizedBox(height: 12),
                      const GlassCard(
                        child: SizedBox(
                          height: 120,
                          child: _MockBarChart(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Queue Section
                      Text("Ca Hôm Nay", style: GlassTheme.h3()),
                      const SizedBox(height: 12),
                      GlassTextField(
                        controller: TextEditingController(text: _searchQuery),
                        label: "Tìm kiếm bệnh nhân",
                        hint: "Tìm kiếm bệnh nhân...",
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ['Tất cả', 'Online', 'Offline', 'Chưa khám', 'Đã khám'].map((filter) {
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ChoiceChip(
                                label: Text(filter),
                                selected: isSelected,
                                selectedColor: GlassTheme.oceanBlue,
                                labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black87),
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _selectedFilter = filter;
                                    });
                                  }
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // List of appointments
                      if (filteredAppointments.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text("Không có lượt khám nào phù hợp."),
                          ),
                        )
                      else
                        ...filteredAppointments.map((appt) => Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                borderColor: appt.status == 'Đang khám'
                                    ? Colors.red
                                    : appt.isOnline
                                        ? Colors.purple.withValues(alpha: 0.3)
                                        : Colors.orange.withValues(alpha: 0.3),
                                child: Material(
                                  color: Colors.transparent,
                                  child: ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: appt.isOnline ? Colors.purple.shade100 : Colors.orange.shade100,
                                      child: Icon(appt.isOnline ? Icons.language : Icons.local_hospital,
                                          color: appt.isOnline ? Colors.purple : Colors.orange),
                                    ),
                                    title: Text("${appt.patientName} (${appt.timeSlot})",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                      "${appt.specialty}\n${appt.symptomSummary}",
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    isThreeLine: true,
                                    trailing: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        StatusBadge(status: appt.status),
                                        const SizedBox(height: 8),
                                        InkWell(
                                          onTap: () => _openWorkspace(appt.id),
                                          child: const Text("Xem →",
                                              style: TextStyle(
                                                  color: GlassTheme.oceanBlue,
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _openWorkspace(appt.id),
                                  ),
                                ),
                              ),
                            )),
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Text(count, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  void _openWorkspace(String apptId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClinicalWorkspace(
          appointmentId: apptId,
          onClosed: () {},
        ),
      ),
    );
  }
}

class _MockBarChart extends StatelessWidget {
  const _MockBarChart();

  @override
  Widget build(BuildContext context) {
    final values = [5, 7, 3, 8, 4, 9, 6];
    final maxVal = 10;
    final days = ["T2", "T3", "T4", "T5", "T6", "T7", "CN"];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final height = (values[index] / maxVal) * 80;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: height,
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(days[index], style: const TextStyle(fontSize: 10, color: Colors.black54)),
          ],
        );
      }),
    );
  }
}
