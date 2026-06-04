import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/role_switcher.dart';
import '../../models/models.dart';
import 'clinical_workspace.dart';

class DoctorTimetableScreen extends StatefulWidget {
  const DoctorTimetableScreen({super.key});

  @override
  State<DoctorTimetableScreen> createState() => _DoctorTimetableScreenState();
}

class _DoctorTimetableScreenState extends State<DoctorTimetableScreen> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month);
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  int get _daysInMonth =>
      DateTime(_currentMonth.year, _currentMonth.month + 1, 0).day;
  int get _firstWeekday => DateTime(_currentMonth.year, _currentMonth.month, 1)
      .weekday; // 1 = Monday, 7 = Sunday

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  // Helper to check if a day has appointments
  bool _hasAppointmentsOnDay(DateTime date) {
    final appState = AppState.instance;
    return appState.appointments.any((appt) => _isSameDay(appt.dateTime, date));
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    // Filter appointments for the selected date
    final selectedAppointments = appState.appointments
        .where((appt) => _isSameDay(appt.dateTime, _selectedDate))
        .toList();

    // Sắp xếp ca khám theo thời gian (dựa vào timeSlot, vd: "08:30 - 09:00")
    selectedAppointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

    return Scaffold(
      appBar: GlassAppBar(
        title: "Lịch Làm Việc",
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton<String>(
            offset: const Offset(0, 56),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            onSelected: (value) {
              if (value == 'switch_role') {
                showDialog(
                  context: context,
                  builder: (ctx) => const RoleSwitcher(),
                );
              } else if (value == 'dashboard') {
                Navigator.pop(context);
              } else if (value == 'logout') {
                // handle logout
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'dashboard',
                child: Row(
                  children: [
                    Icon(Icons.dashboard_outlined,
                        size: 20, color: Colors.black54),
                    SizedBox(width: 12),
                    Text("Bảng điều khiển"),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'toggle_busy',
                child: StatefulBuilder(builder: (context, setPopupState) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.do_not_disturb_on_outlined,
                              size: 20, color: Colors.black54),
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
                }),
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
                    backgroundColor: appState.isDoctorBusy
                        ? Colors.red
                        : GlassTheme.oceanBlue,
                    child: const Icon(Icons.person_pin,
                        color: Colors.white, size: 20),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: GlassBackground(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                )
              ],
            ),
            child: isMobile
                ? Column(
                    children: [
                      _buildCalendarSection(),
                      const SizedBox(height: 16),
                      _buildDetailsSection(selectedAppointments,
                          isMobile: true),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 4, child: _buildCalendarSection()),
                      Container(
                          width: 1,
                          height: 600,
                          color: Colors.grey.withValues(alpha: 0.2)),
                      Expanded(
                          flex: 6,
                          child: _buildDetailsSection(selectedAppointments,
                              isMobile: false)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header: Prev, Month/Year, Next
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon:
                    const Icon(Icons.chevron_left, color: GlassTheme.oceanBlue),
                onPressed: _previousMonth,
                style: IconButton.styleFrom(
                  shape: CircleBorder(
                      side: BorderSide(
                          color: GlassTheme.oceanBlue.withValues(alpha: 0.5))),
                ),
              ),
              Text(
                "Tháng ${_currentMonth.month}, ${_currentMonth.year}",
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GlassTheme.oceanBlue),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right,
                    color: GlassTheme.oceanBlue),
                onPressed: _nextMonth,
                style: IconButton.styleFrom(
                  shape: CircleBorder(
                      side: BorderSide(
                          color: GlassTheme.oceanBlue.withValues(alpha: 0.5))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Days of Week
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ["T2", "T3", "T4", "T5", "T6", "T7", "CN"]
                .map((day) => Expanded(
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          // Calendar Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 42, // 6 rows * 7 days
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final dayOffset = index - (_firstWeekday - 1);
              if (dayOffset < 0 || dayOffset >= _daysInMonth) {
                return const SizedBox.shrink(); // Empty cell
              }

              final date = DateTime(
                  _currentMonth.year, _currentMonth.month, dayOffset + 1);
              final isSelected = _isSameDay(date, _selectedDate);
              final hasAppointments = _hasAppointmentsOnDay(date);
              final isToday = _isSameDay(date, DateTime.now());

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = date;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? GlassTheme.oceanBlue : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        "${date.day}",
                        style: TextStyle(
                          fontWeight: isSelected || isToday
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: isSelected
                              ? Colors.white
                              : (isToday
                                  ? GlassTheme.oceanBlue
                                  : Colors.black87),
                        ),
                      ),
                      if (hasAppointments)
                        Positioned(
                          bottom: 6,
                          child: Container(
                            width: 4,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.amber,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsSection(List<AppAppointment> appointments,
      {bool isMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
      color: isMobile
          ? Colors.transparent
          : const Color(0xFFF8F9FA), // Mobile bỏ màu nền xám
      constraints: const BoxConstraints(minHeight: 600),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Text(
              "Bạn có ${appointments.length} lịch khám ngày ${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}",
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          const SizedBox(height: 16),
          if (appointments.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(
                child: Text(
                  "Không có lịch khám nào trong ngày này.",
                  style: TextStyle(
                      color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ...appointments.map((appt) => _buildTimelineItem(appt)),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(AppAppointment appt) {
    // Tách timeSlot "08:30 - 09:00" thành start và end
    final times = appt.timeSlot.split('-');
    final startTime = times.isNotEmpty ? times[0].trim() : "";
    final endTime = times.length > 1 ? times[1].trim() : "";
    final isOnline = appt.isOnline;
    final statusColor = appt.status == 'Đã khám'
        ? Colors.green
        : (appt.status == 'Đang khám' ? Colors.orange : GlassTheme.oceanBlue);

    bool isOverdue = false;
    if (appt.status == 'Chưa khám' && endTime.isNotEmpty) {
      final parts = endTime.split(':');
      if (parts.length == 2) {
        final endHour = int.tryParse(parts[0]) ?? 0;
        final endMin = int.tryParse(parts[1]) ?? 0;
        final endDateTime = DateTime(appt.dateTime.year, appt.dateTime.month,
            appt.dateTime.day, endHour, endMin);
        if (DateTime.now().isAfter(endDateTime)) {
          isOverdue = true;
        }
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: () {
          // Push sang ClinicalWorkspace đầy đủ màn hình
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                backgroundColor: const Color(0xFFF0F4F8), // Nền nhẹ
                body: SafeArea(
                  child: ClinicalWorkspace(
                    appointmentId: appt.id,
                    onClosed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Cột trái: Loại hình & Giờ
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Text(
                        isOnline ? "Online" : "Offline",
                        style: TextStyle(
                          color: isOnline ? Colors.deepPurple : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Text(startTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                      Text("|",
                          style: TextStyle(
                              color: Colors.grey.withValues(alpha: 0.5),
                              fontSize: 10,
                              height: 1.2)),
                      Text(endTime,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.black87)),
                      const Spacer(),
                    ],
                  ),
                ),

                // Line phân cách đỏ (hoặc xanh)
                Container(
                  width: 3,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: statusColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Cột phải: Thông tin chi tiết
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "${appt.id} - ${appt.patientName}",
                                style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87),
                              ),
                            ),
                            _buildStatusBadge(appt.status),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildSmallDetailRow(
                            Icons.medical_services_outlined, appt.specialty),
                        const SizedBox(height: 4),
                        _buildSmallDetailRow(
                            Icons.location_on_outlined, appt.branchName),
                        const SizedBox(height: 4),
                        _buildSmallDetailRow(
                            Icons.info_outline, appt.symptomSummary),
                        if (isOverdue) ...[
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          "Đã gửi yêu cầu dời lịch hẹn cho bệnh nhân ${appt.patientName}.")),
                                );
                              },
                              icon: const Icon(Icons.notification_important,
                                  size: 16),
                              label: const Text("Gửi thông báo dời lịch"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red.shade50,
                                foregroundColor: Colors.red.shade700,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmallDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    switch (status) {
      case 'Đã khám':
        color = Colors.green;
        break;
      case 'Đang khám':
        color = Colors.orange;
        break;
      default:
        color = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status,
        style:
            TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
