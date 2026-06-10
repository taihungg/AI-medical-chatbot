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
          else if (_selectedFilter == 'Đang khám') { statusMatch = appt.status == 'Đang khám'; }
          else if (_selectedFilter == 'Đã khám') { statusMatch = appt.status == 'Đã khám'; }
          else if (_selectedFilter == 'Online') { statusMatch = appt.isOnline; }
          else if (_selectedFilter == 'Offline') { statusMatch = !appt.isOnline; }

          bool nameMatch = _searchQuery.isEmpty ||
              appt.patientName.toLowerCase().contains(_searchQuery.toLowerCase());
              
          return statusMatch && nameMatch;
        }).toList();

        filteredAppointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

        final pendingQueue = todayAppointments.where((a) => a.status == 'Chưa khám' || a.status == 'Đang khám').toList();
        pendingQueue.sort((a, b) {
          if (a.status == 'Đang khám' && b.status != 'Đang khám') return -1;
          if (b.status == 'Đang khám' && a.status != 'Đang khám') return 1;
          if (a.riskLevel == 'Khẩn cấp' && b.riskLevel != 'Khẩn cấp') return -1;
          if (b.riskLevel == 'Khẩn cấp' && a.riskLevel != 'Khẩn cấp') return 1;
          return a.timeSlot.compareTo(b.timeSlot);
        });

        final nextAppt = pendingQueue.isNotEmpty ? pendingQueue.first : AppAppointment(
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
                );

        return Scaffold(
          body: GlassBackground(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 120.0,
                  floating: false,
                  pinned: true,
                  backgroundColor: Colors.white.withValues(alpha: 0.85),
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 16, right: 0, bottom: 16),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Column(
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
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: Image.asset('assets/logo/app-logo.png', height: 32, width: 32),
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
                            child: _buildStatCard("Chờ khám", countPending.toString(), Icons.pending_actions, Colors.orange, 'Chưa khám'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard("Đang khám", countExamining.toString(), Icons.run_circle_outlined, Colors.red, 'Đang khám'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard("Hoàn thành", countDone.toString(), Icons.check_circle_outline, Colors.green, 'Đã khám'),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard("Trực tuyến", countOnline.toString(), Icons.language, Colors.purple, 'Online'),
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

                      // Custom Bar Chart (Last 7 days)
                      Text("Ca khám 7 ngày qua", style: GlassTheme.h3()),
                      const SizedBox(height: 12),
                      GlassCard(
                        child: SizedBox(
                          height: 120,
                          child: _MockBarChart(appointments: appState.appointments),
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
                      const SizedBox(height: 12),

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
                                    title: Text("${appt.id} • ${appt.patientName}",
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                    subtitle: Text(
                                      "⏰ ${appt.timeSlot}\n${appt.specialty}\n${appt.symptomSummary}",
                                      maxLines: 3,
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

  Widget _buildStatCard(String title, String count, IconData icon, Color color, String filterName) {
    return InkWell(
      onTap: () {
        setState(() {
          if (_selectedFilter == filterName) {
            _selectedFilter = 'Tất cả';
          } else {
            _selectedFilter = filterName;
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        borderColor: _selectedFilter == filterName ? color.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.2),
        borderWidth: _selectedFilter == filterName ? 2.0 : 1.0,
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
      ),
    );
  }

  void _openWorkspace(String apptId) {
    final appState = AppState.instance;
    final appt = appState.appointments.firstWhere((a) => a.id == apptId);
    final hasActive = appState.appointments.any((a) => a.status == 'Đang khám' && a.id != apptId);
    
    if (hasActive && appt.status != 'Đã khám') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Bạn đang có một ca khám chưa hoàn tất. Vui lòng hoàn thành trước khi nhận ca mới."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ClinicalWorkspace(
          appointmentId: apptId,
          onClosed: () {
            setState(() {});
          },
        ),
      ),
    );
  }
}

class _MockBarChart extends StatelessWidget {
  final List<AppAppointment> appointments;
  const _MockBarChart({required this.appointments});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Calculate counts for the last 7 days
    final Map<int, int> counts = {};
    for (int i = 6; i >= 0; i--) {
      counts[i] = 0;
    }
    
    for (var appt in appointments) {
      final apptDate = DateTime(appt.dateTime.year, appt.dateTime.month, appt.dateTime.day);
      final diff = today.difference(apptDate).inDays;
      if (diff >= 0 && diff <= 6) {
        counts[diff] = (counts[diff] ?? 0) + 1;
      }
    }

    final values = [
      counts[6]!, counts[5]!, counts[4]!, counts[3]!, counts[2]!, counts[1]!, counts[0]!
    ];
    
    final maxVal = values.isEmpty ? 1 : (values.reduce((a, b) => a > b ? a : b) + 2);
    
    // Generate labels
    final days = List.generate(7, (index) {
      final d = today.subtract(Duration(days: 6 - index));
      return "${d.day}/${d.month}";
    });

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(7, (index) {
        final val = values[index];
        final height = (val / maxVal) * 80;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(val.toString(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GlassTheme.oceanBlue)),
            const SizedBox(height: 4),
            Container(
              width: 20,
              height: height == 0 ? 4 : height, // min height
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(days[index], style: const TextStyle(fontSize: 10, color: GlassTheme.onSurfaceVariant)),
          ],
        );
      }),
    );
  }
}
