import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../splash_screen.dart';

import 'clinical_workspace.dart';
import 'doctor_components.dart';
import 'doctor_timetable_screen.dart';

class DoctorSpecialistDashboard extends StatefulWidget {
  const DoctorSpecialistDashboard({super.key});

  @override
  State<DoctorSpecialistDashboard> createState() => _DoctorSpecialistDashboardState();
}

class _DoctorSpecialistDashboardState extends State<DoctorSpecialistDashboard> {
  static const String _doctorName = "BS. Nguyễn Văn An";
  String _selectedFilter = 'Tất cả';
  String _searchQuery = '';
  AppAppointment? _selectedAppointment;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 700;

        // Filter appointments for today only
        final now = DateTime.now();
        final todayAppointments = appState.appointments.where((appt) {
          return appt.dateTime.year == now.year && appt.dateTime.month == now.month && appt.dateTime.day == now.day;
        }).toList();

        final filteredAppointments = todayAppointments.where((appt) {
          bool statusMatch = _selectedFilter == 'Tất cả' || appt.status == _selectedFilter;
          bool nameMatch = _searchQuery.isEmpty || appt.patientName.toLowerCase().contains(_searchQuery.toLowerCase());
          return statusMatch && nameMatch;
        }).toList();

        // Sort by timeSlot
        filteredAppointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

        // Counts for badges
        final countAll = todayAppointments.length;
        final countPending = todayAppointments.where((a) => a.status == 'Chưa khám').length;
        final countExamining = todayAppointments.where((a) => a.status == 'Đang khám').length;
        final countDone = todayAppointments.where((a) => a.status == 'Đã khám').length;

        return Scaffold(
          appBar: GlassAppBar(
            title: isMobile ? "Bác Sĩ" : "Cổng Thông Tin Bác Sĩ",
            actions: [
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                tooltip: "Menu Bác sĩ",
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  } else if (value == 'toggle_busy') {
                    appState.toggleDoctorBusy();
                  } else if (value == 'dashboard') {
                    setState(() {
                      _selectedAppointment = null;
                      _selectedFilter = 'Tất cả';
                      _searchQuery = '';
                    });
                  } else if (value == 'appointments') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DoctorTimetableScreen()),
                    );
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'info',
                    enabled: false,
                    child: Text(
                      _doctorName,
                      style: GlassTheme.bodyLg().copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'dashboard',
                    child: Row(
                      children: [
                        Icon(Icons.dashboard_outlined, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text("Trang Chủ"),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'appointments',
                    child: Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text("Lịch Làm Việc"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_busy',
                    child: StatefulBuilder(
                      builder: (context, setPopupState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.do_not_disturb_on_outlined, size: 20, color: Colors.black54),
                                SizedBox(width: 12),
                                Text("Đang bận"),
                              ],
                            ),
                            Switch(
                              value: appState.isDoctorBusy,
                              onChanged: (val) {
                                appState.toggleDoctorBusy();
                                setPopupState(() {});
                              },
                              activeTrackColor: Colors.red.withValues(alpha: 0.5),
                              activeThumbColor: Colors.red,
                              inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
                            ),
                          ],
                        );
                      }
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, color: Colors.red, size: 20),
                        SizedBox(width: 12),
                        Text("Đăng xuất", style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: appState.isDoctorBusy ? Colors.red : GlassTheme.oceanBlue,
                        child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Text(
                          _doctorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: appState.isDoctorBusy ? Colors.red : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: GlassBackground(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN: Queue & Filters
                if (!isMobile || _selectedAppointment == null)
                  Expanded(
                    flex: isMobile ? 1 : 12,
                    child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // 1. Stats Bento cards
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CHƯA KHÁM", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "$countPending ca",
                                    style: GlassTheme.h1(color: GlassTheme.oceanBlue).copyWith(fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (countExamining > 0) ...[
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(12),
                                borderColor: Colors.orange.withValues(alpha: 0.4),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ĐANG KHÁM", style: GlassTheme.labelCaps(color: Colors.orange)),
                                    const SizedBox(height: 6),
                                    Text(
                                      "$countExamining ca",
                                      style: GlassTheme.h1(color: Colors.orange).copyWith(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ĐÃ KHÁM", style: GlassTheme.labelCaps(color: Colors.green)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "$countDone ca",
                                    style: GlassTheme.h1(color: Colors.green).copyWith(fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 2. Search bar
                      TextField(
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        style: GlassTheme.bodyMd(),
                        decoration: InputDecoration(
                          hintText: "Tìm kiếm bệnh nhân...",
                          hintStyle: TextStyle(color: GlassTheme.onSurfaceVariant),
                          prefixIcon: Icon(Icons.search, color: GlassTheme.onSurfaceVariant),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha: 0.4),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Queue Section Title & Filters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Hàng Đợi Hôm Nay", style: GlassTheme.h2()),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${filteredAppointments.length} Ca",
                              style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue).copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Choice chip filter layout with badge counts
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            {'label': 'Tất cả', 'count': countAll},
                            {'label': 'Chưa khám', 'count': countPending},
                            {'label': 'Đang khám', 'count': countExamining},
                            {'label': 'Đã khám', 'count': countDone},
                          ].map((item) {
                            final filter = item['label'] as String;
                            final count = item['count'] as int;
                            final isSelected = _selectedFilter == filter;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedFilter = filter;
                                  });
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected ? GlassTheme.primaryGradient : null,
                                    color: isSelected ? null : Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected ? Colors.transparent : Colors.white38,
                                    ),
                                  ),
                                  child: Text(
                                    "$filter ($count)",
                                    style: GlassTheme.bodyMd(
                                      color: isSelected ? Colors.white : GlassTheme.onSurfaceVariant,
                                    ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 4. Queue List
                      if (filteredAppointments.isEmpty)
                        const GlassCard(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fact_check_outlined, size: 40, color: GlassTheme.outline),
                                SizedBox(height: 10),
                                Text(
                                  "Hàng đợi rỗng trong bộ lọc này",
                                  style: TextStyle(color: GlassTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredAppointments.map((appt) {
                          final isSelected = _selectedAppointment?.id == appt.id;
                          final isDone = appt.status == 'Đã khám';
                          final isExamining = appt.status == 'Đang khám';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedAppointment = appt;
                                });
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderColor: isExamining
                                    ? Colors.orange
                                    : isSelected
                                        ? GlassTheme.oceanBlue
                                        : Colors.white,
                                borderWidth: isSelected || isExamining ? 1.8 : 1.0,
                                opacity: isSelected ? 0.8 : 0.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              appt.id,
                                              style: GlassTheme.labelCaps(color: GlassTheme.outline),
                                            ),
                                            const SizedBox(width: 8),
                                            if (appt.isOnline)
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  "🌐 Trực tuyến",
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                                                ),
                                              )
                                            else
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: const Text(
                                                  "🏥 Trực tiếp",
                                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: GlassTheme.oceanBlue),
                                                ),
                                              ),
                                          ],
                                        ),
                                        StatusBadge(status: appt.status),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(appt.patientName, style: GlassTheme.h3()),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${appt.specialty} • ${appt.timeSlot}",
                                      style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Triệu chứng: ${appt.symptomSummary}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              isDone ? "✓ Đã duyệt" : isExamining ? "⏳ Đang khám" : "Xem hồ sơ",
                                              style: GlassTheme.labelCaps(
                                                color: isDone ? Colors.green : isExamining ? Colors.orange : GlassTheme.oceanBlue,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              isDone ? Icons.check : isExamining ? Icons.medical_services : Icons.arrow_forward_ios,
                                              size: 12,
                                              color: isDone ? Colors.green : isExamining ? Colors.orange : GlassTheme.oceanBlue,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // RIGHT SIDEBAR / CLINICAL WORKSPACE
                if (_selectedAppointment != null)
                  Expanded(
                    flex: isMobile ? 1 : 18,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isMobile ? Colors.transparent : Colors.white.withValues(alpha: 0.4),
                            width: isMobile ? 0 : 1,
                          ),
                        ),
                      ),
                      child: ClinicalWorkspace(
                        appointmentId: _selectedAppointment!.id,
                        onClosed: () {
                          setState(() {
                            _selectedAppointment = null;
                          });
                        },
                      ),
                    ),
                  )
                else if (!isMobile)
                  const Expanded(
                    flex: 18,
                    child: Center(
                      child: GlassCard(
                        width: 320,
                        margin: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_ind_outlined, size: 48, color: GlassTheme.oceanBlue),
                            SizedBox(height: 16),
                            Text(
                              "Chưa Chọn Ca Khám",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Vui lòng chọn một bệnh nhân từ hàng đợi bên trái để bắt đầu cuộc tư vấn và lập bệnh án lâm sàng.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: GlassTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}