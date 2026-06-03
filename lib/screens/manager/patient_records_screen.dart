import 'package:flutter/material.dart';
import '../../widgets/glass_widgets.dart';

class Patient {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String gender;
  final String lastVisit;
  final String category;
  final String healthStatus; // 'Ổn định', 'Khẩn cấp'
  final String aiSymptomSummary;

  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.lastVisit,
    required this.category,
    required this.healthStatus,
    required this.aiSymptomSummary,
  });
}

class PatientRecordsScreen extends StatefulWidget {
  const PatientRecordsScreen({super.key});

  @override
  State<PatientRecordsScreen> createState() => _PatientRecordsScreenState();
}

class _PatientRecordsScreenState extends State<PatientRecordsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Tất cả';

  // Mock data mô phỏng dữ liệu kết hợp Symptom Flow
  final List<Patient> _allPatients = [
    Patient(
      id: 'BN-8801',
      name: 'Trần Thế Bảo',
      phone: '0901234567',
      age: 45,
      gender: 'Nam',
      lastVisit: 'Hôm nay',
      category: 'Khách mới',
      healthStatus: 'Khẩn cấp',
      aiSymptomSummary:
          'Bệnh nhân báo cáo đau đầu dữ dội vùng thái dương kéo dài 3 ngày, kèm buồn nôn nhẹ. Huyết áp đo tại nhà (theo lời khai) là 150/95. AI phân loại nguy cơ cao (Red Flag), đề xuất khám chuyên khoa Thần Kinh ngay lập tức.',
    ),
    Patient(
      id: 'BN-8802',
      name: 'Lê Thị Thu Thảo',
      phone: '0987654321',
      age: 32,
      gender: 'Nữ',
      lastVisit: '12/05/2026',
      category: 'Tái khám',
      healthStatus: 'Ổn định',
      aiSymptomSummary:
          'Bệnh nhân tái khám định kỳ trào ngược dạ dày. Các triệu chứng ợ chua đã giảm 80% sau 2 tuần dùng thuốc theo toa cũ. Không có triệu chứng mới phát sinh. AI đánh giá tiến triển tốt.',
    ),
    Patient(
      id: 'BN-8803',
      name: 'Vũ Hoàng Minh',
      phone: '0911223344',
      age: 50,
      gender: 'Nam',
      lastVisit: '01/05/2026',
      category: 'Cần theo dõi',
      healthStatus: 'Khẩn cấp',
      aiSymptomSummary:
          'Chỉ số đường huyết (tự đo) tăng đột biến lên 12 mmol/L trong 2 ngày qua. Bệnh nhân có biểu hiện mệt mỏi, khát nước nhiều. AI cảnh báo rủi ro biến chứng tiểu đường, yêu cầu liên hệ bệnh nhân gấp.',
    ),
    Patient(
      id: 'BN-8804',
      name: 'Nguyễn Ngọc Anh',
      phone: '0933445566',
      age: 28,
      gender: 'Nữ',
      lastVisit: 'Hôm qua',
      category: 'Khách mới',
      healthStatus: 'Ổn định',
      aiSymptomSummary:
          'Triệu chứng cảm cúm thông thường: Sốt nhẹ 37.8, sổ mũi, ho khan. Đã test nhanh Covid-19 âm tính. AI dự đoán viêm hô hấp trên do virus, đề xuất tư vấn Telehealth để cấp thuốc giảm triệu chứng.',
    ),
  ];

  late List<Patient> _filteredPatients;

  final List<String> _filters = [
    'Tất cả',
    'Khách mới',
    'Tái khám',
    'Cần theo dõi'
  ];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
  }

  void _filterPatients() {
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        // Shneiderman: Tìm kiếm thông minh qua Tên HOẶC Số điện thoại
        final searchLower = _searchQuery.toLowerCase();
        final matchSearch = p.name.toLowerCase().contains(searchLower) ||
            p.phone.contains(searchLower) ||
            p.id.toLowerCase().contains(searchLower);

        final matchFilter =
            _selectedFilter == 'Tất cả' || p.category == _selectedFilter;
        return matchSearch && matchFilter;
      }).toList();
    });
  }

  // Dialog Tích hợp Dữ liệu AI
  void _showPatientDetailDialog(Patient patient) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                borderRadius: 24,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Hồ sơ chi tiết',
                              style: GlassTheme.h2(color: GlassTheme.primary)),
                          IconButton(
                            icon: const Icon(Icons.close,
                                color: GlassTheme.outline),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Thông tin cơ bản
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor:
                                GlassTheme.oceanBlue.withValues(alpha: 0.2),
                            child: Icon(
                              patient.gender == 'Nam'
                                  ? Icons.face
                                  : Icons.face_3,
                              size: 30,
                              color: GlassTheme.oceanBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(patient.name, style: GlassTheme.h3()),
                                Text(
                                    '${patient.id} • ${patient.age} tuổi • ${patient.gender}',
                                    style: GlassTheme.bodyMd(
                                        color: GlassTheme.onSurfaceVariant)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone,
                                        size: 14, color: GlassTheme.outline),
                                    const SizedBox(width: 4),
                                    Text(patient.phone,
                                        style: GlassTheme.bodyMd(
                                            color:
                                                GlassTheme.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Khu vực Dữ liệu AI (Symptom Flow Integration)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.deepPurple.withValues(alpha: 0.1),
                              Colors.blueAccent.withValues(alpha: 0.05)
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                              color: Colors.deepPurple.withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.auto_awesome,
                                    color: Colors.deepPurple, size: 20),
                                const SizedBox(width: 8),
                                Text('Lịch sử khai báo triệu chứng (AI)',
                                    style:
                                        GlassTheme.h3(color: Colors.deepPurple)
                                            .copyWith(fontSize: 16)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              patient.aiSymptomSummary,
                              style:
                                  GlassTheme.bodyMd(color: GlassTheme.onSurface)
                                      .copyWith(height: 1.5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: GlassButton(
                          text: 'Xem Bệnh án đầy đủ',
                          icon: Icons.assignment_ind,
                          onPressed: () {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Chuyển hướng đến màn hình Bệnh án chi tiết...')),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic)),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('Quản lý Bệnh nhân',
              style: GlassTheme.h2(color: GlassTheme.primary)),
          iconTheme: const IconThemeData(color: GlassTheme.primary),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thanh Search (Reduce memory load)
              GlassTextField(
                controller: _searchController,
                label: '',
                hint: 'Tìm theo Tên hoặc Số điện thoại...',
                prefixIcon: Icons.search,
                suffixIcon: _searchQuery.isNotEmpty ? Icons.close : null,
                onSuffixPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _filterPatients();
                  });
                },
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                    _filterPatients();
                  });
                },
              ),
              const SizedBox(height: 16),

              // Hàng Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                            _filterPatients();
                          });
                        },
                        selectedColor:
                            GlassTheme.oceanBlue.withValues(alpha: 0.25),
                        backgroundColor: Colors.white.withValues(alpha: 0.4),
                        labelStyle: TextStyle(
                          color: isSelected
                              ? GlassTheme.primary
                              : GlassTheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? GlassTheme.oceanBlue
                              : Colors.transparent,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Danh sách / Empty State
              Expanded(
                child: _filteredPatients.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: _filteredPatients.length,
                        itemBuilder: (context, index) {
                          final patient = _filteredPatients[index];
                          final isUrgent = patient.healthStatus == 'Khẩn cấp';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showPatientDetailDialog(patient),
                                borderRadius: BorderRadius.circular(20),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(16.0),
                                  borderRadius: 20,
                                  borderColor: isUrgent
                                      ? GlassTheme.error.withValues(alpha: 0.3)
                                      : Colors.white,
                                  child: Row(
                                    children: [
                                      // Avatar
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: GlassTheme.cyan
                                            .withValues(alpha: 0.2),
                                        child: Icon(
                                          patient.gender == 'Nam'
                                              ? Icons.face
                                              : Icons.face_3,
                                          color: GlassTheme.oceanBlue,
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      // Thông tin bệnh nhân
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(patient.name,
                                                style: GlassTheme.h3()),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${patient.id} • ${patient.gender}, ${patient.age} tuổi',
                                              style: GlassTheme.bodyMd(
                                                  color: GlassTheme
                                                      .onSurfaceVariant),
                                            ),
                                            const SizedBox(height: 8),
                                            // Badges trạng thái (Visibility)
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 4,
                                              children: [
                                                _buildStatusBadge(
                                                  text: patient.category,
                                                  color: GlassTheme.oceanBlue,
                                                ),
                                                _buildStatusBadge(
                                                  text: patient.healthStatus,
                                                  color: isUrgent
                                                      ? GlassTheme.error
                                                      : Colors.green,
                                                  icon: isUrgent
                                                      ? Icons
                                                          .warning_amber_rounded
                                                      : Icons
                                                          .check_circle_outline,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Icon mũi tên (Affordances)
                                      Icon(Icons.chevron_right,
                                          color: GlassTheme.outline
                                              .withValues(alpha: 0.5),
                                          size: 28),
                                    ],
                                  ),
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

  Widget _buildStatusBadge(
      {required String text, required Color color, IconData? icon}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(text,
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  // Friendly Empty State (Error Prevention / Feedback)
  Widget _buildEmptyState() {
    return Center(
      child: GlassCard(
        padding: const EdgeInsets.all(32),
        borderRadius: 24,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.search_off_rounded,
                  size: 64, color: GlassTheme.oceanBlue.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            Text(
              'Không tìm thấy hồ sơ',
              style: GlassTheme.h2(color: GlassTheme.onSurface),
            ),
            const SizedBox(height: 12),
            Text(
              'Không có hồ sơ bệnh nhân nào khớp với từ khóa "$_searchQuery" hoặc bộ lọc hiện tại. Vui lòng kiểm tra lại số điện thoại/tên.',
              textAlign: TextAlign.center,
              style: GlassTheme.bodyMd(color: GlassTheme.outline),
            ),
            const SizedBox(height: 24),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'Tất cả')
              GlassButton(
                text: 'Xóa bộ lọc',
                height: 48,
                width: 200,
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchQuery = '';
                    _selectedFilter = 'Tất cả';
                    _filterPatients();
                  });
                },
              )
          ],
        ),
      ),
    );
  }
}
