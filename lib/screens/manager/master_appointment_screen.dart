import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class Appointment {
  final String id;
  final String patientName;
  final String doctorName;
  final String specialty;
  final String time;
  final String serviceType; // 'Khám trực tuyến (Telehealth)', 'Khám tại phòng khám (Clinic Visit)'
  String status; // 'Chờ duyệt', 'Đã xác nhận', 'Đã hủy'
  String? cancelReason;

  Appointment({
    required this.id,
    required this.patientName,
    required this.doctorName,
    required this.specialty,
    required this.time,
    required this.serviceType,
    required this.status,
    this.cancelReason,
  });
}

class MasterAppointmentScreen extends StatefulWidget {
  const MasterAppointmentScreen({super.key});

  @override
  State<MasterAppointmentScreen> createState() => _MasterAppointmentScreenState();
}

class _MasterAppointmentScreenState extends State<MasterAppointmentScreen> {
  // Mock data tích hợp luồng appointment_booking và clinic_visit_recommended
  final List<Appointment> _appointments = [
    Appointment(
      id: 'APT-001', 
      patientName: 'Trần Thế Bảo', 
      doctorName: 'BS. Nguyễn Văn An', 
      specialty: 'Khoa Tim mạch', 
      time: '08:30 - Hôm nay', 
      serviceType: 'Khám trực tuyến (Telehealth)',
      status: 'Chờ duyệt',
    ),
    Appointment(
      id: 'APT-002', 
      patientName: 'Lê Thị Thu Thảo', 
      doctorName: 'BS. Lê Thị Bình', 
      specialty: 'Khoa Nội', 
      time: '09:15 - Hôm nay', 
      serviceType: 'Khám tại phòng khám (Clinic Visit)',
      status: 'Chờ duyệt',
    ),
    Appointment(
      id: 'APT-003', 
      patientName: 'Vũ Hoàng Minh', 
      doctorName: 'BS. Trần Quốc Đạt', 
      specialty: 'Khoa Thần kinh', 
      time: '14:00 - Hôm qua', 
      serviceType: 'Khám trực tuyến (Telehealth)',
      status: 'Đã xác nhận',
    ),
    Appointment(
      id: 'APT-004', 
      patientName: 'Nguyễn Ngọc Anh', 
      doctorName: 'BS. Phạm Minh Tâm', 
      specialty: 'Khoa Tim mạch', 
      time: '10:00 - 29/05', 
      serviceType: 'Khám tại phòng khám (Clinic Visit)',
      status: 'Đã hủy',
      cancelReason: 'Bệnh nhân bận việc đột xuất',
    ),
  ];

  void _approveAppointment(Appointment apt) {
    setState(() {
      apt.status = 'Đã xác nhận';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Đã phê duyệt lịch hẹn cho bệnh nhân ${apt.patientName}.')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showCancelDialog(Appointment apt) {
    final TextEditingController reasonController = TextEditingController();

    // Shneiderman: Cho phép đảo ngược hành động (AlertDialog)
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: GlassTheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              const Icon(Icons.warning_rounded, color: GlassTheme.error),
              const SizedBox(width: 8),
              Text('Xác nhận Hủy Lịch', style: GlassTheme.h2(color: GlassTheme.error).copyWith(fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn hủy lịch hẹn của bệnh nhân ${apt.patientName} vào lúc ${apt.time}?',
                style: GlassTheme.bodyMd(),
              ),
              const SizedBox(height: 16),
              GlassTextField(
                controller: reasonController,
                label: 'Lý do hủy (Tùy chọn)',
                hint: 'Nhập lý do...',
                prefixIcon: Icons.edit_note,
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Lối thoát an toàn (Reversal)
              child: Text('Đóng', style: TextStyle(color: GlassTheme.outline, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _cancelAppointment(apt, reasonController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: GlassTheme.error,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Xác nhận Hủy', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _cancelAppointment(Appointment apt, String reason) {
    setState(() {
      apt.status = 'Đã hủy';
      if (reason.isNotEmpty) {
        apt.cancelReason = reason;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.cancel, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text('Đã hủy lịch hẹn của ${apt.patientName}.')),
          ],
        ),
        backgroundColor: GlassTheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildAppointmentList(String filterStatus) {
    final list = _appointments.where((a) {
      if (filterStatus == 'Lịch sử') {
        return a.status == 'Đã hủy' || a.status == 'Hoàn thành';
      }
      return a.status == filterStatus;
    }).toList();

    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: GlassTheme.outline.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Không có lịch hẹn nào.', style: GlassTheme.h3(color: GlassTheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final apt = list[index];
        final isPending = apt.status == 'Chờ duyệt';
        final isTelehealth = apt.serviceType.contains('Telehealth');

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            borderRadius: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Mã lịch hẹn & Badge Trạng thái)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(apt.id, style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPending 
                            ? Colors.orange.withOpacity(0.2) 
                            : (apt.status == 'Đã hủy' ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        apt.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPending 
                              ? Colors.orange[800] 
                              : (apt.status == 'Đã hủy' ? Colors.red[800] : Colors.green[800]),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Body (Avatar & Thông tin cơ bản)
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: GlassTheme.oceanBlue.withOpacity(0.15),
                      child: const Icon(Icons.person, color: GlassTheme.oceanBlue),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(apt.patientName, style: GlassTheme.h3()),
                          const SizedBox(height: 4),
                          Text(
                            '${apt.doctorName} • ${apt.specialty}',
                            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.access_time, size: 14, color: GlassTheme.outline),
                              const SizedBox(width: 4),
                              Text(apt.time, style: GlassTheme.bodyMd(color: GlassTheme.outline).copyWith(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Service Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isTelehealth ? Colors.blueAccent.withOpacity(0.1) : Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isTelehealth ? Colors.blueAccent.withOpacity(0.3) : Colors.teal.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(isTelehealth ? Icons.video_camera_front : Icons.local_hospital, size: 16, color: isTelehealth ? Colors.blueAccent : Colors.teal),
                      const SizedBox(width: 8),
                      Text(
                        apt.serviceType, 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isTelehealth ? Colors.blueAccent : Colors.teal)
                      ),
                    ],
                  ),
                ),
                
                if (apt.cancelReason != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Colors.red),
                        const SizedBox(width: 4),
                        Expanded(child: Text('Lý do hủy: ${apt.cancelReason}', style: const TextStyle(fontSize: 12, color: Colors.red, fontStyle: FontStyle.italic))),
                      ],
                    ),
                  )
                ],

                // Norman Constraints: Nút hành động bị ẩn hoàn toàn nếu không ở trạng thái "Chờ duyệt"
                if (isPending) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Divider(color: Colors.black12, height: 1),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton.icon(
                        onPressed: () => _showCancelDialog(apt),
                        icon: const Icon(Icons.close, color: GlassTheme.error, size: 18),
                        label: const Text('Từ chối', style: TextStyle(color: GlassTheme.error, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: () => _approveAppointment(apt),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GlassTheme.oceanBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 4,
                          shadowColor: GlassTheme.oceanBlue.withOpacity(0.4),
                        ),
                        icon: const Icon(Icons.check, color: Colors.white, size: 18),
                        label: const Text('Phê duyệt', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ]
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Text('Điều phối Lịch hẹn', style: GlassTheme.h2(color: GlassTheme.primary)),
            iconTheme: const IconThemeData(color: GlassTheme.primary),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(60),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: TabBar(
                  indicator: BoxDecoration(
                    color: GlassTheme.oceanBlue,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(color: GlassTheme.oceanBlue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2)),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: GlassTheme.onSurfaceVariant,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  tabs: const [
                    Tab(text: 'Chờ duyệt'),
                    Tab(text: 'Đã xác nhận'),
                    Tab(text: 'Lịch sử/Đã hủy'),
                  ],
                ),
              ),
            ),
          ),
          body: TabBarView(
            children: [
              _buildAppointmentList('Chờ duyệt'),
              _buildAppointmentList('Đã xác nhận'),
              _buildAppointmentList('Lịch sử'), // Hàm _buildAppointmentList xử lý gộp trạng thái 'Đã hủy'
            ],
          ),
        ),
      ),
    );
  }
}
