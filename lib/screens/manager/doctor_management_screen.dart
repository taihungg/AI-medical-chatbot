import 'package:flutter/material.dart';

// MÀU SẮC GIAO DIỆN PHẲNG (Chuẩn Y Tế)
const Color medicalBlue = Color(0xFF2563EB); // bg-blue-600
const Color backgroundLight = Color(0xFFF9FAFB); // bg-gray-50
const Color surfaceWhite = Colors.white;
const Color textPrimary = Color(0xFF111827); // gray-900
const Color textSecondary = Color(0xFF6B7280); // gray-500
const Color borderLight = Color(0xFFE5E7EB); // gray-200
const Color errorRed = Color(0xFFDC2626); // red-600
const Color successGreen = Color(0xFF059669); // emerald-600
const Color warningYellow = Color(0xFFD97706); // amber-600

class Doctor {
  final String id;
  String name;
  String specialty;
  String status; 
  String phone;
  String email;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.status,
    required this.phone,
    this.email = '',
  });
}

class DoctorManagementScreen extends StatefulWidget {
  const DoctorManagementScreen({super.key});

  @override
  State<DoctorManagementScreen> createState() => _DoctorManagementScreenState();
}

class _DoctorManagementScreenState extends State<DoctorManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialty = 'Tất cả';

  final List<Doctor> _allDoctors = [
    Doctor(id: 'BS01', name: 'Nguyễn Văn An', specialty: 'Khoa Tim mạch', status: 'Đang hoạt động', phone: '0901234567', email: 'an.nguyen@aicare.vn'),
    Doctor(id: 'BS02', name: 'Lê Thị Bình', specialty: 'Răng Hàm Mặt', status: 'Tạm nghỉ', phone: '0912345678', email: 'binh.le@aicare.vn'),
    Doctor(id: 'BS03', name: 'Trần Quốc Đạt', specialty: 'Khoa Thần kinh', status: 'Đã khóa', phone: '0987654321', email: 'dat.tran@aicare.vn'),
    Doctor(id: 'BS04', name: 'Phạm Minh Tâm', specialty: 'Da liễu', status: 'Đang hoạt động', phone: '0909998887', email: 'tam.pham@aicare.vn'),
    Doctor(id: 'BS05', name: 'Hoàng Minh Tuấn', specialty: 'Khoa Ngoại', status: 'Đang hoạt động', phone: '0903332211', email: 'tuan.hoang@aicare.vn'),
  ];

  late List<Doctor> _filteredDoctors;
  final List<String> _specialties = ['Khoa Tim mạch', 'Khoa Nội tổng quát', 'Khoa Thần kinh', 'Khoa Ngoại', 'Răng Hàm Mặt', 'Da liễu'];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _filteredDoctors = _allDoctors;
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        final matchSearch = doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            doc.phone.contains(_searchQuery);
        final matchSpecialty = _selectedSpecialty == 'Tất cả' || doc.specialty == _selectedSpecialty;
        return matchSearch && matchSpecialty;
      }).toList();
    });
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? errorRed : successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _deleteDoctor(Doctor doctor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xác nhận xóa', style: TextStyle(fontWeight: FontWeight.bold, color: errorRed)),
        content: Text('Bạn có chắc chắn muốn xóa hồ sơ bác sĩ ${doctor.name}? Thao tác này không thể hoàn tác.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy', style: TextStyle(color: textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _allDoctors.removeWhere((d) => d.id == doctor.id);
                _filterDoctors();
              });
              _showFeedback('Đã xóa bác sĩ ${doctor.name}');
            },
            style: ElevatedButton.styleFrom(backgroundColor: errorRed),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: backgroundLight,
      endDrawer: _buildRightDrawerForm(), // Trượt từ sát mép phải
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP TOOLBAR
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quản lý Bác sĩ',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
                ),
                Row(
                  children: [
                    // Thanh Tìm kiếm
                    Container(
                      width: 280,
                      height: 44,
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        border: Border.all(color: borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm theo tên, SĐT...',
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
                                      _filterDoctors();
                                    });
                                  },
                                )
                              : null,
                        ),
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                            _filterDoctors();
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Dropdown Lọc chuyên khoa
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: surfaceWhite,
                        border: Border.all(color: borderLight),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSpecialty,
                          icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary),
                          items: ['Tất cả', ..._specialties].map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 14)))).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSpecialty = val;
                                _filterDoctors();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Call-To-Action Button
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Mở Drawer thêm bác sĩ mới
                          _scaffoldKey.currentState?.openEndDrawer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: medicalBlue,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                        ),
                        icon: const Icon(Icons.add, size: 20),
                        label: const Text('Thêm Bác sĩ', style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ],
                ),
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
                  boxShadow: const [
                    BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
                  ],
                  border: Border.all(color: borderLight),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48), // Trải dài full width
                          child: DataTable(
                            headingRowColor: WidgetStateProperty.all(backgroundLight),
                            columnSpacing: 32,
                            horizontalMargin: 24,
                            columns: const [
                              DataColumn(label: Text('Thông tin Bác sĩ', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                              DataColumn(label: Text('Chuyên khoa', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                              DataColumn(label: Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                              DataColumn(label: Text('Trạng thái', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                              DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                            ],
                            rows: _filteredDoctors.map((doc) {
                              return DataRow(
                                cells: [
                                  // Cột Thông tin (Avatar + Tên + Email)
                                  DataCell(
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: medicalBlue.withOpacity(0.1),
                                          child: Text(
                                            doc.name.substring(0, 1),
                                            style: const TextStyle(color: medicalBlue, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(doc.name, style: const TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                                            Text(doc.email, style: const TextStyle(fontSize: 12, color: textSecondary)),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  // Cột Chuyên khoa (Badge)
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: medicalBlue.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(doc.specialty, style: const TextStyle(color: medicalBlue, fontSize: 13, fontWeight: FontWeight.w500)),
                                    ),
                                  ),
                                  // Số điện thoại
                                  DataCell(Text(doc.phone, style: const TextStyle(color: textPrimary))),
                                  // Trạng thái
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: (doc.status == 'Đang hoạt động' ? successGreen : warningYellow).withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        doc.status, 
                                        style: TextStyle(
                                          color: doc.status == 'Đang hoạt động' ? successGreen : warningYellow, 
                                          fontSize: 13, 
                                          fontWeight: FontWeight.w500
                                        )
                                      ),
                                    ),
                                  ),
                                  // Cột Hành động (Outline Icons)
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 20, color: textSecondary),
                                          hoverColor: medicalBlue.withOpacity(0.1),
                                          onPressed: () {
                                            // Handle edit
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 20, color: textSecondary),
                                          hoverColor: errorRed.withOpacity(0.1),
                                          onPressed: () => _deleteDoctor(doc),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    // Phân trang
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: borderLight)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hiển thị 1-${_filteredDoctors.length} trên tổng ${_allDoctors.length}', style: const TextStyle(color: textSecondary, fontSize: 13)),
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

  // 3. KHU VỰC THÊM BÁC SĨ (RIGHT DRAWER)
  Widget _buildRightDrawerForm() {
    return Drawer(
      width: 420, // Khoảng 30-40% màn hình
      backgroundColor: surfaceWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), // Thiết kế phẳng vuông vức
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drawer Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: borderLight))),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Thêm Bác sĩ mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                IconButton(
                  icon: const Icon(Icons.close, color: textSecondary),
                  onPressed: () => Navigator.pop(context),
                  hoverColor: backgroundLight,
                )
              ],
            ),
          ),

          // Drawer Body (Scrollable)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Drag & Drop zone
                  const Text('Ảnh đại diện (Avatar)', style: TextStyle(fontWeight: FontWeight.w600, color: textPrimary)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      color: backgroundLight,
                      borderRadius: BorderRadius.circular(8),
                      // Tạo border nét đứt giả lập
                      border: Border.all(color: borderLight, style: BorderStyle.solid, width: 2), // Flutter ko hỗ trợ trực tiếp dashed border dễ dàng, dùng viền mờ thay thế
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.cloud_upload_outlined, color: textSecondary, size: 32),
                        SizedBox(height: 8),
                        Text('Kéo thả ảnh vào đây hoặc nhấn để tải lên', style: TextStyle(color: textSecondary, fontSize: 13)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Họ và Tên (*)
                  _buildInputLabel('Họ và Tên', isRequired: true),
                  TextField(
                    decoration: _inputDecoration('VD: Nguyễn Văn A'),
                  ),
                  const SizedBox(height: 20),

                  // Số điện thoại (*) + Demo Error
                  _buildInputLabel('Số điện thoại', isRequired: true),
                  TextField(
                    decoration: _inputDecoration('Chỉ nhập số').copyWith(
                      focusedBorder: OutlineInputBorder(borderSide: const BorderSide(color: errorRed), borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(borderSide: const BorderSide(color: errorRed), borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Text('Vui lòng chỉ nhập số hợp lệ', style: TextStyle(color: errorRed, fontSize: 12)),
                  ),
                  const SizedBox(height: 20),

                  // Email (*)
                  _buildInputLabel('Email', isRequired: true),
                  TextField(
                    decoration: _inputDecoration('VD: doctor@aicare.vn'),
                  ),
                  const SizedBox(height: 20),

                  // Chuyên khoa (Dropdown)
                  _buildInputLabel('Chuyên khoa', isRequired: true),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(border: Border.all(color: borderLight), borderRadius: BorderRadius.circular(8)),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _specialties.first,
                        icon: const Icon(Icons.keyboard_arrow_down, color: textSecondary),
                        items: _specialties.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (val) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Drawer Sticky Footer
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              color: surfaceWhite,
              border: Border(top: BorderSide(color: borderLight)),
              boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 10, offset: Offset(0, -4))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: borderLight),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Hủy', style: TextStyle(color: textPrimary, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Logic Lưu
                    Navigator.pop(context);
                    _showFeedback('Lưu thông tin thành công!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: medicalBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  child: const Text('Lưu Thông Tin', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildInputLabel(String label, {bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: RichText(
        text: TextSpan(
          text: label,
          style: const TextStyle(fontWeight: FontWeight.w600, color: textPrimary, fontSize: 14),
          children: [
            if (isRequired) const TextSpan(text: ' *', style: TextStyle(color: errorRed)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: textSecondary, fontSize: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderLight)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: borderLight)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: medicalBlue)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}
