import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class Doctor {
  final String id;
  String name;
  String specialty;
  String branch;
  String status; // 'Hoạt động', 'Nghỉ phép', 'Đã khóa'
  String phone;
  String email;
  int pendingPrescriptions;
  int finalizedPrescriptions;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.branch,
    required this.status,
    required this.phone,
    this.email = '',
    this.pendingPrescriptions = 0,
    this.finalizedPrescriptions = 0,
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

  // Mock data mô phỏng từ AppState
  final List<Doctor> _allDoctors = [
    Doctor(
        id: 'BS01',
        name: 'Nguyễn Văn An',
        specialty: 'Khoa Tim mạch',
        branch: 'Chi nhánh Quận 1',
        status: 'Hoạt động',
        phone: '0901234567',
        email: 'an.nguyen@aicare.vn',
        pendingPrescriptions: 5,
        finalizedPrescriptions: 12),
    Doctor(
        id: 'BS02',
        name: 'Lê Thị Bình',
        specialty: 'Khoa Nội tổng quát',
        branch: 'Chi nhánh Hoàn Kiếm',
        status: 'Nghỉ phép',
        phone: '0912345678',
        email: 'binh.le@aicare.vn',
        pendingPrescriptions: 0,
        finalizedPrescriptions: 8),
    Doctor(
        id: 'BS03',
        name: 'Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        branch: 'Chi nhánh Hải Châu',
        status: 'Đã khóa',
        phone: '0987654321',
        email: 'dat.tran@aicare.vn',
        pendingPrescriptions: 0,
        finalizedPrescriptions: 0),
    Doctor(
        id: 'BS04',
        name: 'Phạm Minh Tâm',
        specialty: 'Khoa Tim mạch',
        branch: 'Chi nhánh Quận 1',
        status: 'Hoạt động',
        phone: '0909998887',
        email: 'tam.pham@aicare.vn',
        pendingPrescriptions: 12,
        finalizedPrescriptions: 45),
  ];

  late List<Doctor> _filteredDoctors;

  final List<String> _specialties = [
    'Khoa Tim mạch',
    'Khoa Nội tổng quát',
    'Khoa Thần kinh',
    'Khoa Nhi',
    'Nha khoa'
  ];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = _allDoctors;
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        final matchSearch =
            doc.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                doc.id.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchSpecialty = _selectedSpecialty == 'Tất cả' ||
            doc.specialty == _selectedSpecialty;
        return matchSearch && matchSpecialty;
      }).toList();
    });
  }

  // Hệ thống Feedback toàn cục
  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle,
                color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? GlassTheme.error : GlassTheme.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Tính năng Khóa/Mở khóa tài khoản (Permit easy reversal of actions)
  void _toggleLockDoctor(Doctor doctor) {
    if (doctor.status == 'Đã khóa') {
      // Mở khóa luôn không cần cảnh báo gắt gao
      setState(() {
        doctor.status = 'Hoạt động';
        _filterDoctors();
      });
      _showFeedback('Đã mở khóa tài khoản bác sĩ ${doctor.name}');
      return;
    }

    // Hiển thị Dialog cảnh báo trước khi khóa
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GlassTheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Xác nhận khóa tài khoản',
            style: GlassTheme.h2(color: GlassTheme.error)),
        content: Text(
          'Bạn có chắc chắn muốn khóa tài khoản của bác sĩ ${doctor.name}?\nBác sĩ này sẽ không thể đăng nhập vào hệ thống.',
          style: GlassTheme.bodyMd(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(), // Đảo ngược/Hủy an toàn
            child: Text('Hủy', style: TextStyle(color: GlassTheme.outline)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              setState(() {
                doctor.status = 'Đã khóa';
                _filterDoctors();
              });
              _showFeedback(
                  'Đã khóa tài khoản bác sĩ ${doctor.name} thành công!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GlassTheme.error,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Xác nhận khóa',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Hiển thị Form Thêm/Sửa bằng TopSheet (Trượt từ trên xuống)
  void _showDoctorFormDialog({Doctor? existingDoctor}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.4),
      transitionDuration: const Duration(milliseconds: 400),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Align(
          alignment: Alignment.topCenter,
          child: Material(
            color: Colors.transparent,
            child: DoctorFormBottomSheet(
              doctor: existingDoctor,
              specialties: _specialties,
              onSave: (name, phone, email, specialty) {
                setState(() {
                  if (existingDoctor != null) {
                    existingDoctor.name = name;
                    existingDoctor.phone = phone;
                    existingDoctor.email = email;
                    existingDoctor.specialty = specialty;
                    _showFeedback(
                        'Đã cập nhật thông tin bác sĩ $name thành công!');
                  } else {
                    final newId =
                        'BS${(_allDoctors.length + 1).toString().padLeft(2, '0')}';
                    _allDoctors.insert(
                      0,
                      Doctor(
                        id: newId,
                        name: name,
                        specialty: specialty,
                        branch: 'Chi nhánh Trung tâm',
                        status: 'Hoạt động',
                        phone: phone,
                        email: email,
                      ),
                    );
                    _showFeedback('Đã thêm bác sĩ $name thành công!');
                  }
                  _filterDoctors();
                });
              },
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1),
            end: const Offset(0, 0),
          ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filterSpecialties = ['Tất cả', ..._specialties];

    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Quản lý Bác sĩ',
              style: GlassTheme.h2(color: GlassTheme.primary)),
          iconTheme: const IconThemeData(color: GlassTheme.primary),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showDoctorFormDialog(),
          backgroundColor: GlassTheme.oceanBlue,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Thêm Bác sĩ',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh Search & Filter (Reduce memory load)
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: GlassTextField(
                      controller: _searchController,
                      label: '',
                      hint: 'Tìm tên hoặc ID...',
                      prefixIcon: Icons.search,
                      suffixIcon: _searchQuery.isNotEmpty ? Icons.close : null,
                      onSuffixPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _filterDoctors();
                        });
                      },
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                          _filterDoctors();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 1,
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      borderRadius: 16,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedSpecialty,
                          isExpanded: true,
                          icon: const Icon(Icons.filter_list,
                              color: GlassTheme.oceanBlue),
                          items: filterSpecialties
                              .map((s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(s, style: GlassTheme.bodyMd())))
                              .toList(),
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
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Danh sách Bác sĩ
              Expanded(
                child: _filteredDoctors.isEmpty
                    ? Center(
                        child: Text(
                          'Không tìm thấy bác sĩ nào.',
                          style: GlassTheme.bodyLg(
                              color: GlassTheme.onSurfaceVariant),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredDoctors.length,
                        itemBuilder: (context, index) {
                          final doctor = _filteredDoctors[index];
                          final isLocked = doctor.status == 'Đã khóa';

                          // Ràng buộc (Constraints): Nếu khóa thì giảm opacity và đổi màu
                          return Opacity(
                            opacity: isLocked ? 0.6 : 1.0,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16.0),
                                borderRadius: 20,
                                // Color logic
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 30,
                                      backgroundColor: isLocked
                                          ? Colors.grey.withValues(alpha: 0.2)
                                          : GlassTheme.oceanBlue
                                              .withValues(alpha: 0.2),
                                      child: Text(
                                        doctor.name.substring(0, 1),
                                        style: GlassTheme.h2(
                                            color: isLocked
                                                ? Colors.grey
                                                : GlassTheme.oceanBlue),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(doctor.name,
                                              style: GlassTheme.h3(
                                                  color: isLocked
                                                      ? Colors.grey
                                                      : GlassTheme.onSurface)),
                                          const SizedBox(height: 4),
                                          Text(
                                              '${doctor.id} • ${doctor.specialty}',
                                              style: GlassTheme.bodyMd(
                                                  color: isLocked
                                                      ? Colors.grey
                                                      : GlassTheme
                                                          .onSurfaceVariant)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                isLocked
                                                    ? Icons.lock
                                                    : (doctor.status ==
                                                            'Hoạt động'
                                                        ? Icons.check_circle
                                                        : Icons.pause_circle),
                                                size: 14,
                                                color: isLocked
                                                    ? Colors.grey
                                                    : (doctor.status ==
                                                            'Hoạt động'
                                                        ? Colors.green
                                                        : Colors.orange),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                doctor.status,
                                                style: GlassTheme.labelCaps(
                                                  color: isLocked
                                                      ? Colors.grey
                                                      : (doctor.status ==
                                                              'Hoạt động'
                                                          ? Colors.green
                                                          : Colors.orange),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          // Sign Finalize Prescription Tracker Badge (Visibility & Feedback)
                                          if (!isLocked)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                _buildPrescriptionBadge(
                                                  icon: Icons.pending_actions,
                                                  count: doctor
                                                      .pendingPrescriptions,
                                                  label: 'Chờ duyệt',
                                                  color: Colors.orange,
                                                ),
                                                _buildPrescriptionBadge(
                                                  icon: Icons.fact_check,
                                                  count: doctor
                                                      .finalizedPrescriptions,
                                                  label: 'Đã ký',
                                                  color: Colors.green,
                                                ),
                                              ],
                                            )
                                        ],
                                      ),
                                    ),

                                    // Action Buttons
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        // Edit Button (Constraint: Bị disable khi đã khóa)
                                        IconButton(
                                          icon: Icon(Icons.edit,
                                              color: isLocked
                                                  ? Colors.grey
                                                  : GlassTheme.oceanBlue),
                                          tooltip: 'Sửa thông tin',
                                          onPressed: isLocked
                                              ? null
                                              : () => _showDoctorFormDialog(
                                                  existingDoctor: doctor),
                                        ),
                                        // Lock/Unlock Button
                                        IconButton(
                                          icon: Icon(
                                              isLocked
                                                  ? Icons.lock_open
                                                  : Icons.lock_outline,
                                              color: isLocked
                                                  ? Colors.green
                                                  : GlassTheme.error),
                                          tooltip: isLocked
                                              ? 'Mở khóa'
                                              : 'Khóa tài khoản',
                                          onPressed: () =>
                                              _toggleLockDoctor(doctor),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPrescriptionBadge(
      {required IconData icon,
      required int count,
      required String label,
      required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text('$count $label',
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

// Widget BottomSheet cho Form Thêm/Sửa
class DoctorFormBottomSheet extends StatefulWidget {
  final Doctor? doctor;
  final List<String> specialties;
  final Function(String name, String phone, String email, String specialty)
      onSave;

  const DoctorFormBottomSheet(
      {super.key,
      this.doctor,
      required this.specialties,
      required this.onSave});

  @override
  State<DoctorFormBottomSheet> createState() => _DoctorFormBottomSheetState();
}

class _DoctorFormBottomSheetState extends State<DoctorFormBottomSheet> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _emailCtrl;
  late String _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.doctor?.name ?? '');
    _phoneCtrl = TextEditingController(text: widget.doctor?.phone ?? '');
    _emailCtrl = TextEditingController(text: widget.doctor?.email ?? '');
    _selectedSpecialty = widget.doctor?.specialty ?? widget.specialties.first;

    // Add listeners to rebuild UI for button validation
    _nameCtrl.addListener(() => setState(() {}));
    _phoneCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  bool _isValid() {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final email = _emailCtrl.text.trim();

    if (name.isEmpty || phone.isEmpty || email.isEmpty) return false;

    // Simple RegEx validations
    final phoneRegExp = RegExp(r'^[0-9]+$');
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!phoneRegExp.hasMatch(phone) || phone.length < 10) return false;
    if (!emailRegExp.hasMatch(email)) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    // Add padding bottom for keyboard
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.9),
      padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: topPadding + 16,
          bottom: bottomPadding + 24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doctor == null ? 'Thêm Bác sĩ Mới' : 'Chỉnh sửa Bác sĩ',
              style: GlassTheme.h2(color: GlassTheme.primary),
            ),
            const SizedBox(height: 24),

            // Name
            GlassTextField(
              controller: _nameCtrl,
              label: 'Họ và Tên',
              hint: 'VD: Nguyễn Văn A',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            // Dropdown Specialty (Error Prevention - Không cho tự gõ)
            GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              borderRadius: 16,
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedSpecialty,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: GlassTheme.oceanBlue),
                  items: widget.specialties
                      .map((s) => DropdownMenuItem(
                          value: s, child: Text(s, style: GlassTheme.bodyMd())))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedSpecialty = val);
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            GlassTextField(
              controller: _phoneCtrl,
              label: 'Số điện thoại',
              hint: 'Chỉ nhập số',
              prefixIcon: Icons.phone_android,
            ),
            const SizedBox(height: 16),

            // Email
            GlassTextField(
              controller: _emailCtrl,
              label: 'Email',
              hint: 'VD: doctor@aicare.vn',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 32),

            // Nút Lưu (Constraint: Disable nếu form không hợp lệ)
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _isValid()
                    ? () {
                        widget.onSave(
                            _nameCtrl.text.trim(),
                            _phoneCtrl.text.trim(),
                            _emailCtrl.text.trim(),
                            _selectedSpecialty);
                        Navigator.of(context).pop();
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: GlassTheme.oceanBlue,
                  disabledBackgroundColor: Colors.grey[300],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  elevation: _isValid() ? 4 : 0,
                ),
                child: Text('Lưu Thông Tin',
                    style: TextStyle(
                      color: _isValid() ? Colors.white : Colors.grey[500],
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
