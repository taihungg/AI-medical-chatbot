import 'package:flutter/material.dart';

// MÀU SẮC GIAO DIỆN PHẲNG (Chuẩn Y Tế)
const Color medicalBlue = Color(0xFF2563EB); // bg-blue-600
const Color backgroundLight = Color(0xFFF8FAFC); // bg-slate-50
const Color surfaceWhite = Colors.white;
const Color textPrimary = Color(0xFF0F172A); // slate-900
const Color textSecondary = Color(0xFF64748B); // slate-500
const Color borderLight = Color(0xFFE2E8F0); // slate-200
const Color hoverRowColor = Color(0xFFF8FAFC); // bg-gray-50/slate-50 hover

// Màu cho Badge
const Color urgentBg = Color(0xFFFEE2E2); // red-100
const Color urgentText = Color(0xFFDC2626); // red-600
const Color stableBg = Color(0xFFD1FAE5); // emerald-100
const Color stableText = Color(0xFF059669); // emerald-600

const Color categoryBg = Color(0xFFDBEAFE); // blue-100
const Color categoryText = Color(0xFF1E40AF); // blue-800

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

  // Mock data
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
      aiSymptomSummary: 'Bệnh nhân báo cáo đau đầu dữ dội vùng thái dương kéo dài 3 ngày, kèm buồn nôn nhẹ. Huyết áp đo tại nhà (theo lời khai) là 150/95. AI phân loại nguy cơ cao (Red Flag), đề xuất khám chuyên khoa Thần Kinh ngay lập tức.',
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
      aiSymptomSummary: 'Bệnh nhân tái khám định kỳ trào ngược dạ dày. Các triệu chứng ợ chua đã giảm 80% sau 2 tuần dùng thuốc theo toa cũ. Không có triệu chứng mới phát sinh. AI đánh giá tiến triển tốt.',
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
      aiSymptomSummary: 'Chỉ số đường huyết (tự đo) tăng đột biến lên 12 mmol/L trong 2 ngày qua. Bệnh nhân có biểu hiện mệt mỏi, khát nước nhiều. AI cảnh báo rủi ro biến chứng tiểu đường, yêu cầu liên hệ bệnh nhân gấp.',
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
      aiSymptomSummary: 'Triệu chứng cảm cúm thông thường: Sốt nhẹ 37.8, sổ mũi, ho khan. Đã test nhanh Covid-19 âm tính. AI dự đoán viêm hô hấp trên do virus, đề xuất tư vấn Telehealth để cấp thuốc giảm triệu chứng.',
    ),
  ];

  late List<Patient> _filteredPatients;
  final List<String> _filters = ['Tất cả', 'Khách mới', 'Tái khám', 'Cần theo dõi'];

  @override
  void initState() {
    super.initState();
    _filteredPatients = _allPatients;
  }

  void _filterPatients() {
    setState(() {
      _filteredPatients = _allPatients.where((p) {
        final searchLower = _searchQuery.toLowerCase();
        final matchSearch = p.name.toLowerCase().contains(searchLower) ||
            p.phone.contains(searchLower) ||
            p.id.toLowerCase().contains(searchLower);
            
        final matchFilter = _selectedFilter == 'Tất cả' || p.category == _selectedFilter;
        return matchSearch && matchFilter;
      }).toList();
    });
  }

  void _showPatientDetailDialog(Patient patient) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) {
        return Align(
          alignment: Alignment.center,
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              constraints: BoxConstraints(maxWidth: 600, maxHeight: MediaQuery.of(context).size.height * 0.8),
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 16)],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hồ sơ chi tiết', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary)),
                          IconButton(
                            icon: const Icon(Icons.close, color: textSecondary),
                            onPressed: () => Navigator.of(context).pop(),
                          )
                        ],
                      ),
                      const Divider(color: borderLight, height: 24),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: categoryBg,
                            child: Icon(
                              patient.gender == 'Nam' ? Icons.face : Icons.face_3,
                              size: 30,
                              color: medicalBlue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(patient.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
                                const SizedBox(height: 4),
                                Text('${patient.id} • ${patient.age} tuổi • ${patient.gender}', style: const TextStyle(color: textSecondary)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: textSecondary),
                                    const SizedBox(width: 4),
                                    Text(patient.phone, style: const TextStyle(color: textSecondary)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      
                      // Khu vực Dữ liệu AI 
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4), // green-50
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)), // green-200
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.auto_awesome, color: stableText, size: 20),
                                SizedBox(width: 8),
                                Text('Lịch sử khai báo triệu chứng (AI)', style: TextStyle(fontWeight: FontWeight.bold, color: stableText)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              patient.aiSymptomSummary,
                              style: const TextStyle(color: textPrimary, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: medicalBlue,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: const Icon(Icons.assignment_ind, size: 20),
                          label: const Text('Xem Bệnh án đầy đủ', style: TextStyle(fontWeight: FontWeight.w600)),
                          onPressed: () {
                            Navigator.of(context).pop();
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
            // 1. TOP CONTROLS
            const Text(
              'Quản lý Bệnh nhân',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                // Dòng 1: Search bar
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
                      hintText: 'Tìm kiếm theo tên, SĐT bệnh nhân...',
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
                                  _filterPatients();
                                });
                              },
                            )
                          : null,
                    ),
                    onChanged: (val) {
                      setState(() {
                        _searchQuery = val;
                        _filterPatients();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Dòng 2: Tabs (Pills) lọc bệnh nhân
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _selectedFilter = filter;
                          _filterPatients();
                        });
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? categoryBg : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          filter,
                          style: TextStyle(
                            color: isSelected ? categoryText : textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
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
                  children: [
                    Expanded(
                      child: _filteredPatients.isEmpty
                          ? _buildEmptyState()
                          : SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 48),
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(surfaceWhite),
                                  dataRowMaxHeight: 64,
                                  dataRowMinHeight: 64,
                                  columnSpacing: 32,
                                  horizontalMargin: 24,
                                  border: const TableBorder(bottom: BorderSide(color: borderLight)),
                                  columns: const [
                                    DataColumn(label: Text('Bệnh nhân', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    DataColumn(label: Text('Thông tin cơ bản', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    DataColumn(label: Text('Phân loại', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    DataColumn(label: Text('Tình trạng', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                    DataColumn(label: Text('Hành động', style: TextStyle(fontWeight: FontWeight.w600, color: textSecondary))),
                                  ],
                                  rows: _filteredPatients.map((patient) {
                                    final isUrgent = patient.healthStatus == 'Khẩn cấp';
                                    
                                    return DataRow(
                                      color: WidgetStateProperty.resolveWith<Color?>((Set<WidgetState> states) {
                                        if (states.contains(WidgetState.hovered)) {
                                          return hoverRowColor;
                                        }
                                        return null; 
                                      }),
                                      cells: [
                                        // Cột 1: Avatar + Tên + ID
                                        DataCell(
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 18,
                                                backgroundColor: categoryBg,
                                                child: Icon(
                                                  patient.gender == 'Nam' ? Icons.face : Icons.face_3,
                                                  color: medicalBlue,
                                                  size: 18,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold, color: textPrimary, fontSize: 14)),
                                                  Text(patient.id, style: const TextStyle(color: textSecondary, fontSize: 12)),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        // Cột 2: Thông tin cơ bản
                                        DataCell(
                                          Text('${patient.gender}, ${patient.age} tuổi', style: const TextStyle(color: textPrimary)),
                                        ),
                                        // Cột 3: Phân loại (Badge)
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: categoryBg,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(patient.category, style: const TextStyle(color: categoryText, fontSize: 13, fontWeight: FontWeight.w500)),
                                          ),
                                        ),
                                        // Cột 4: Tình trạng (Badge Khẩn cấp/Ổn định)
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: isUrgent ? urgentBg : stableBg,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(isUrgent ? Icons.warning_amber_rounded : Icons.check_circle_outline, size: 14, color: isUrgent ? urgentText : stableText),
                                                const SizedBox(width: 4),
                                                Text(
                                                  patient.healthStatus, 
                                                  style: TextStyle(
                                                    color: isUrgent ? urgentText : stableText, 
                                                    fontSize: 13, 
                                                    fontWeight: FontWeight.bold
                                                  )
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        // Cột 5: Hành động
                                        DataCell(
                                          IconButton(
                                            icon: const Icon(Icons.chevron_right, color: textSecondary),
                                            onPressed: () => _showPatientDetailDialog(patient),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                    ),
                    // Thanh phân trang
                    if (_filteredPatients.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: const BoxDecoration(
                          border: Border(top: BorderSide(color: borderLight)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hiển thị 1-${_filteredPatients.length} trên tổng ${_allPatients.length}', style: const TextStyle(color: textSecondary, fontSize: 13)),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: backgroundLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded, size: 64, color: borderLight),
          ),
          const SizedBox(height: 24),
          const Text(
            'Không tìm thấy hồ sơ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textPrimary),
          ),
          const SizedBox(height: 12),
          Text(
            'Không có hồ sơ bệnh nhân nào khớp với từ khóa "$_searchQuery".',
            textAlign: TextAlign.center,
            style: const TextStyle(color: textSecondary),
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty || _selectedFilter != 'Tất cả')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: surfaceWhite,
                foregroundColor: textPrimary,
                side: const BorderSide(color: borderLight),
                elevation: 0,
              ),
              child: const Text('Xóa bộ lọc'),
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
    );
  }
}
