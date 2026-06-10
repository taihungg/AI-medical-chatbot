import 'package:flutter/material.dart';

// MÀU SẮC GIAO DIỆN PHẲNG (Chuẩn Y Tế)
const Color medicalBlue = Color(0xFF2563EB); // bg-blue-600
const Color backgroundLight = Color(0xFFF8FAFC); // bg-slate-50
const Color surfaceWhite = Colors.white;
const Color textPrimary = Color(0xFF0F172A); // slate-900
const Color textSecondary = Color(0xFF64748B); // slate-500
const Color textMuted = Color(0xFF94A3B8); // slate-400
const Color borderLight = Color(0xFFE2E8F0); // slate-200
const Color hoverRowColor = Color(0xFFF8FAFC); // hover

// Màu cho Badge Loại hình khám
const Color telehealthBg = Color(0xFFDBEAFE); // blue-100
const Color telehealthText = Color(0xFF1E40AF); // blue-800
const Color clinicBg = Color(0xFFD1FAE5); // emerald-100
const Color clinicText = Color(0xFF059669); // emerald-600

const Color errorRed = Color(0xFFDC2626); // red-600

class Appointment {
  final String id;
  final String patientName;
  final String doctorName;
  final String specialty;
  final String time;
  final String serviceType; // 'Khám trực tuyến (Telehealth)', 'Khám tại phòng khám (Clinic Visit)'
  String status; // 'Chờ duyệt', 'Đã xác nhận', 'Đã hủy', 'Hoàn thành'
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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTabIndex = 0; // 0: Chờ duyệt, 1: Đã xác nhận, 2: Lịch sử/Đã hủy

  final List<Appointment> _allAppointments = [
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
      serviceType: 'Khám tại phòng khám',
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
      serviceType: 'Khám tại phòng khám',
      status: 'Đã hủy',
      cancelReason: 'Bệnh nhân bận việc đột xuất',
    ),
  ];

  late List<Appointment> _filteredAppointments;

  @override
  void initState() {
    super.initState();
    _filterAppointments();
  }

  void _filterAppointments() {
    setState(() {
      _filteredAppointments = _allAppointments.where((apt) {
        // Lọc theo Search Query
        final searchLower = _searchQuery.toLowerCase();
        final matchSearch = apt.patientName.toLowerCase().contains(searchLower) ||
            apt.id.toLowerCase().contains(searchLower) ||
            apt.doctorName.toLowerCase().contains(searchLower);

        // Lọc theo Tab (0: Chờ duyệt, 1: Đã xác nhận, 2: Lịch sử)
        bool matchTab = false;
        if (_selectedTabIndex == 0) {
          matchTab = apt.status == 'Chờ duyệt';
        } else if (_selectedTabIndex == 1) {
          matchTab = apt.status == 'Đã xác nhận';
        } else if (_selectedTabIndex == 2) {
          matchTab = apt.status == 'Đã hủy' || apt.status == 'Hoàn thành';
        }

        return matchSearch && matchTab;
      }).toList();
    });
  }

  void _approveAppointment(Appointment apt) {
    setState(() {
      apt.status = 'Đã xác nhận';
      _filterAppointments();
    });
    _showFeedback('Đã phê duyệt lịch hẹn cho bệnh nhân ${apt.patientName}.', false);
  }

  void _showCancelDialog(Appointment apt) {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.warning_rounded, color: errorRed),
              SizedBox(width: 8),
              Text('Xác nhận Hủy Lịch', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: errorRed)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn có chắc chắn muốn hủy lịch hẹn của bệnh nhân ${apt.patientName} vào lúc ${apt.time}?',
                style: const TextStyle(color: textPrimary),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: InputDecoration(
                  labelText: 'Lý do hủy (Tùy chọn)',
                  hintText: 'Nhập lý do...',
                  prefixIcon: const Icon(Icons.edit_note, color: textSecondary),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), 
              child: const Text('Đóng', style: TextStyle(color: textSecondary, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  apt.status = 'Đã hủy';
                  if (reasonController.text.isNotEmpty) {
                    apt.cancelReason = reasonController.text;
                  }
                  _filterAppointments();
                });
                _showFeedback('Đã hủy lịch hẹn của ${apt.patientName}.', true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: errorRed,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Xác nhận Hủy', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showFeedback(String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.cancel : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? errorRed : const Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundLight,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP CONTROLS (Row 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Điều phối Lịch hẹn',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                Row(
                  children: [
                    // Thanh Tìm kiếm
                    Container(
                      width: 320,
                      height: 44,
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        border: Border.all(color: borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm mã lịch, tên bệnh nhân...',
                          hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
                          prefixIcon: const Icon(Icons.search, color: textSecondary, size: 20),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                      _filterAppointments();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _filterAppointments();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Date Picker giả lập
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        border: Border.all(color: borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.calendar_today_outlined, size: 18, color: textSecondary),
                          SizedBox(width: 8),
                          Text('Hôm nay', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w500)),
                          SizedBox(width: 8),
                          Icon(Icons.keyboard_arrow_down, size: 18, color: textSecondary),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 1. TOP CONTROLS (Row 2 - Tabs Điều hướng)
            Row(
              children: [
                _buildTab(0, 'Chờ duyệt'),
                const SizedBox(width: 32),
                _buildTab(1, 'Đã xác nhận'),
                const SizedBox(width: 32),
                _buildTab(2, 'Lịch sử/Đã hủy'),
              ],
            ),
            const SizedBox(height: 24),

            // 2. DATA TABLE
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1))],
                  border: Border.all(color: borderLight),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _filteredAppointments.isEmpty
                          ? _buildEmptyState()
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(surfaceWhite),
                                  dataRowMaxHeight: 80,
                                  dataRowMinHeight: 80,
                                  columnSpacing: 32,
                                  horizontalMargin: 24,
                                  border: const TableBorder(bottom: BorderSide(color: borderLight)),
                                  columns: [
                                    const DataColumn(label: Text('Mã lịch', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    const DataColumn(label: Text('Bệnh nhân & Bác sĩ', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    const DataColumn(label: Text('Thời gian', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    const DataColumn(label: Text('Loại hình khám', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    DataColumn(
                                      // Chỉ hiển thị cột Hành động nếu đang ở Tab Chờ duyệt, nếu không thì để trống hoặc Hành động xem
                                      label: Container(
                                        alignment: Alignment.centerRight,
                                        width: 200,
                                        child: Text(_selectedTabIndex == 0 ? 'Hành động' : '', style: const TextStyle(fontWeight: FontWeight.w600, color: textSecondary)),
                                      ),
                                    ),
                                  ],
                                  rows: _filteredAppointments.map((apt) {
                                    final isTelehealth = apt.serviceType.contains('Telehealth');
                                    
                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (states.contains(WidgetState.hovered)) return hoverRowColor;
                                        return null; 
                                      }),
                                      cells: [
                                        // Mã lịch
                                        DataCell(Text(apt.id, style: const TextStyle(color: textMuted, fontWeight: FontWeight.w500))),
                                        // Bệnh nhân & Bác sĩ
                                        DataCell(
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(apt.patientName, style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 15)),
                                              const SizedBox(height: 4),
                                              Text('${apt.doctorName} - ${apt.specialty}', style: const TextStyle(color: textSecondary, fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        // Thời gian
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(Icons.access_time, size: 16, color: textSecondary),
                                              const SizedBox(width: 6),
                                              Text(apt.time, style: const TextStyle(color: textPrimary, fontWeight: FontWeight.bold, fontSize: 14)),
                                            ],
                                          ),
                                        ),
                                        // Loại hình khám
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isTelehealth ? telehealthBg : clinicBg,
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              apt.serviceType.split('(').first.trim(), // Lấy tên ngắn gọn
                                              style: TextStyle(
                                                color: isTelehealth ? telehealthText : clinicText, 
                                                fontSize: 13, 
                                                fontWeight: FontWeight.w600
                                              )
                                            ),
                                          ),
                                        ),
                                        // Hành động (Căn phải có Margin an toàn - Fat-finger prevention)
                                        DataCell(
                                          Container(
                                            alignment: Alignment.centerRight,
                                            child: _selectedTabIndex == 0 
                                              ? Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Nút Từ chối
                                                    OutlinedButton(
                                                      onPressed: () => _showCancelDialog(apt),
                                                      style: OutlinedButton.styleFrom(
                                                        foregroundColor: errorRed,
                                                        side: const BorderSide(color: errorRed),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      ),
                                                      child: const Text('Từ chối', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ),
                                                    const SizedBox(width: 12), // Khoảng cách an toàn
                                                    // Nút Phê duyệt
                                                    ElevatedButton.icon(
                                                      onPressed: () => _approveAppointment(apt),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor: medicalBlue,
                                                        foregroundColor: Colors.white,
                                                        elevation: 0,
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                                      ),
                                                      icon: const Icon(Icons.check, size: 18),
                                                      label: const Text('Phê duyệt', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ),
                                                  ],
                                                )
                                              : (_selectedTabIndex == 2 && apt.cancelReason != null)
                                                  // Nếu ở tab Lịch sử và có lý do hủy
                                                  ? Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        const Icon(Icons.info_outline, size: 16, color: errorRed),
                                                        const SizedBox(width: 4),
                                                        Text('Lý do hủy: ${apt.cancelReason}', style: const TextStyle(color: errorRed, fontStyle: FontStyle.italic, fontSize: 13)),
                                                      ],
                                                    )
                                                  : const SizedBox.shrink(),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),
                    // Pagination
                    if (_filteredAppointments.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: const BoxDecoration(border: Border(top: BorderSide(color: borderLight))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hiển thị 1-${_filteredAppointments.length} kết quả', style: const TextStyle(color: textSecondary, fontSize: 13)),
                            Row(
                              children: [
                                OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: borderLight)),
                                  child: const Text('Trước', style: TextStyle(color: textSecondary)),
                                ),
                                const SizedBox(width: 8),
                                OutlinedButton(
                                  onPressed: null,
                                  style: OutlinedButton.styleFrom(side: const BorderSide(color: borderLight)),
                                  child: const Text('Sau', style: TextStyle(color: textSecondary)),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String title) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
          _filterAppointments();
        });
      },
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? medicalBlue : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? medicalBlue : textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(color: backgroundLight, shape: BoxShape.circle),
            child: const Icon(Icons.event_busy, size: 64, color: borderLight),
          ),
          const SizedBox(height: 24),
          const Text('Không có lịch hẹn nào', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
          const SizedBox(height: 12),
          Text(
            'Không tìm thấy dữ liệu khớp với bộ lọc hiện tại.',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textSecondary),
          ),
        ],
      ),
    );
  }
}
