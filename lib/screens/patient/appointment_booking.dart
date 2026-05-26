import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() => _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  int _activeStep = 0;

  // Selected data states
  String _selectedBranch = "Phòng khám A - Quận 1, TP. HCM";
  String _selectedSpecialty = "Khoa Tim mạch";
  String _selectedDoctor = "BS. Nguyễn Văn An";
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = "09:00 - 09:30";

  final List<String> _branches = [
    "Phòng khám A - Quận 1, TP. HCM",
    "Phòng khám B - Hoàn Kiếm, Hà Nội",
    "Phòng khám C - Hải Châu, Đà Nẵng",
    "Phòng khám D - Ninh Kiều, Cần Thơ"
  ];

  final List<Map<String, String>> _doctors = [
    {"name": "BS. Nguyễn Văn An", "spec": "Khoa Tim mạch", "exp": "15 năm kinh nghiệm"},
    {"name": "BS. Lê Thị Bình", "spec": "Khoa Nội tổng quát", "exp": "12 năm kinh nghiệm"},
    {"name": "BS. Trần Quốc Đạt", "spec": "Khoa Thần kinh", "exp": "10 năm kinh nghiệm"},
    {"name": "BS. Phạm Minh Tuấn", "spec": "Khoa Nhi", "exp": "8 năm kinh nghiệm"},
  ];

  final List<String> _timeSlots = [
    "08:00 - 08:30",
    "09:00 - 09:30",
    "10:15 - 10:45",
    "11:00 - 11:30",
    "14:00 - 14:30",
    "15:15 - 15:45",
    "16:00 - 16:30"
  ];

  // Helper calendar dates (next 7 days)
  List<DateTime> _getBookingDates() {
    return List.generate(7, (idx) => DateTime.now().add(Duration(days: idx + 1)));
  }

  String _getWeekdayVi(int day) {
    switch (day) {
      case 1: return "Thứ 2";
      case 2: return "Thứ 3";
      case 3: return "Thứ 4";
      case 4: return "Thứ 5";
      case 5: return "Thứ 6";
      case 6: return "Thứ 7";
      default: return "Chủ Nhật";
    }
  }

  void _nextStep() {
    if (_activeStep < 3) {
      setState(() {
        _activeStep++;
      });
    } else {
      _finalizeBooking();
    }
  }

  void _prevStep() {
    if (_activeStep > 0) {
      setState(() {
        _activeStep--;
      });
    }
  }

  void _finalizeBooking() {
    final appState = AppState.instance;

    appState.bookAppointment(
      patientName: "Nguyễn Minh Anh",
      branch: _selectedBranch,
      doctor: _selectedDoctor,
      specialty: _selectedSpecialty,
      date: _selectedDate,
      slot: _selectedSlot,
      symptoms: appState.selectedSymptomsText.isNotEmpty
          ? appState.selectedSymptomsText
          : "Đăng ký khám tổng quát ban đầu.",
      risk: appState.currentRiskLevel,
    );

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          borderColor: GlassTheme.cyan,
          borderWidth: 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                "Đăng Ký Thành Công!",
                style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Lịch hẹn khám tại $_selectedBranch với $_selectedDoctor đã được thiết lập.",
                style: GlassTheme.bodyMd(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                text: "Hoàn tất",
                onPressed: () {
                  Navigator.of(ctx).pop(); // pop dialog
                  Navigator.of(context).pop(); // pop booking wizard screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GlassAppBar(
        title: "Đặt Lịch Khám Cơ Sở",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GlassTheme.oceanBlue),
          onPressed: _prevStep,
        ),
      ),
      body: GlassBackground(
        child: Column(
          children: [
            // Horizontal Step Indicators
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(4, (idx) {
                  final active = _activeStep == idx;
                  final done = _activeStep > idx;
                  return Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: active
                              ? GlassTheme.oceanBlue
                              : (done ? Colors.green : Colors.white60),
                        ),
                        child: Center(
                          child: done
                              ? const Icon(Icons.check, size: 14, color: Colors.white)
                              : Text(
                                  "${idx + 1}",
                                  style: GlassTheme.labelCaps(
                                    color: active ? Colors.white : GlassTheme.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                      if (idx < 3)
                        Container(
                          width: 40,
                          height: 2,
                          color: done ? Colors.green : Colors.white30,
                        ),
                    ],
                  );
                }),
              ),
            ),

            // Step Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _buildStepContent(),
              ),
            ),

            // Bottom Navigation triggers
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 110),
              child: Row(
                children: [
                  if (_activeStep > 0) ...[
                    Expanded(
                      child: GlassButton(
                        text: "Quay lại",
                        isPrimary: false,
                        onPressed: _prevStep,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: GlassButton(
                      text: _activeStep == 3 ? "Xác nhận đặt lịch" : "Tiếp theo",
                      onPressed: _nextStep,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_activeStep) {
      case 0:
        return _buildBranchSelection();
      case 1:
        return _buildDoctorSelection();
      case 2:
        return _buildDateTimeSelection();
      default:
        return _buildReviewConfirmation();
    }
  }

  // Visual content builders

  Widget _buildBranchSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BƯỚC 1: CHỌN CHI NHÁNH PHÒNG KHÁM", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
        const SizedBox(height: 12),
        Text(
          "Hệ thống AI Care Bridge hỗ trợ đặt hẹn nhanh tại 4 cơ sở phòng khám tích hợp.",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ..._branches.map((br) {
          final isSel = _selectedBranch == br;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedBranch = br;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                borderColor: isSel ? GlassTheme.cyan : Colors.white,
                borderWidth: isSel ? 2 : 1,
                opacity: isSel ? 0.8 : 0.6,
                child: Row(
                  children: [
                    Radio<String>(
                      activeColor: GlassTheme.oceanBlue,
                      value: br,
                      groupValue: _selectedBranch,
                      onChanged: (val) {
                        setState(() {
                          _selectedBranch = val!;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            br.split(" - ").first,
                            style: GlassTheme.h3().copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            br.split(" - ").last,
                            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.location_on, color: isSel ? GlassTheme.oceanBlue : GlassTheme.outline, size: 20),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDoctorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BƯỚC 2: CHỌN BÁC SĨ CHUYÊN KHOA", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
        const SizedBox(height: 12),
        Text(
          "Đội ngũ bác sĩ chuyên khoa đã được chứng thực lâm sàng trên hệ thống.",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        ..._doctors.map((doc) {
          final isSel = _selectedDoctor == doc["name"];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedDoctor = doc["name"]!;
                  _selectedSpecialty = doc["spec"]!;
                });
              },
              borderRadius: BorderRadius.circular(16),
              child: GlassCard(
                borderColor: isSel ? GlassTheme.cyan : Colors.white,
                borderWidth: isSel ? 2 : 1,
                opacity: isSel ? 0.8 : 0.6,
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSel ? GlassTheme.oceanBlue.withOpacity(0.12) : Colors.white38,
                      ),
                      child: Center(
                        child: Icon(Icons.person, color: isSel ? GlassTheme.oceanBlue : GlassTheme.outline, size: 26),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc["name"]!,
                            style: GlassTheme.h3().copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            doc["spec"]!,
                            style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue).copyWith(fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            doc["exp"]!,
                            style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    if (isSel)
                      const Icon(Icons.check_circle, color: GlassTheme.oceanBlue),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    final dates = _getBookingDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BƯỚC 3: CHỌN NGÀY & KHUNG GIỜ KHÁM", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
        const SizedBox(height: 16),
        
        // 1. Horizontal Date Picker
        Text("1. Chọn ngày khám:", style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: dates.length,
            itemBuilder: (ctx, index) {
              final d = dates[index];
              final isSel = _selectedDate.day == d.day && _selectedDate.month == d.month;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDate = d;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    borderColor: isSel ? GlassTheme.oceanBlue : Colors.white30,
                    borderWidth: isSel ? 2 : 1,
                    opacity: isSel ? 0.9 : 0.4,
                    width: 76,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getWeekdayVi(d.weekday),
                          style: GlassTheme.labelCaps(
                            color: isSel ? GlassTheme.oceanBlue : GlassTheme.onSurfaceVariant,
                          ).copyWith(fontSize: 9),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "${d.day}/${d.month}",
                          style: GlassTheme.h3(
                            color: isSel ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                          ).copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 24),

        // 2. Time slots selection grid
        Text("2. Chọn khung giờ khám:", style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _timeSlots.map((slot) {
            final isSel = _selectedSlot == slot;
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedSlot = slot;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: GlassCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                borderColor: isSel ? GlassTheme.oceanBlue : Colors.white30,
                borderWidth: isSel ? 1.8 : 1.0,
                opacity: isSel ? 0.9 : 0.45,
                child: Text(
                  slot,
                  style: GlassTheme.bodyMd(
                    color: isSel ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                  ).copyWith(
                    fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewConfirmation() {
    final appState = AppState.instance;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BƯỚC 4: RÀ SOÁT LỊCH HẸN Y KHOA", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
        const SizedBox(height: 12),
        Text(
          "Hãy xác thực toàn bộ thông tin đăng ký bên dưới trước khi ký xác nhận.",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        GlassCard(
          borderColor: GlassTheme.cyan,
          borderWidth: 1.5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Branch info
              _buildReviewRow(Icons.location_on, "Cơ sở điều trị", _selectedBranch),
              const Divider(color: Colors.white30, height: 24),
              // Doctor info
              _buildReviewRow(Icons.person, "Bác sĩ chuyên khoa", "$_selectedDoctor\n($_selectedSpecialty)"),
              const Divider(color: Colors.white30, height: 24),
              // Time slot
              _buildReviewRow(
                Icons.calendar_today,
                "Thời gian khám",
                "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\nGiờ khám: $_selectedSlot",
              ),
              const Divider(color: Colors.white30, height: 24),
              // Symptom Summary
              _buildReviewRow(
                Icons.sick_outlined,
                "Triệu chứng đã khai báo",
                appState.selectedSymptomsText.isNotEmpty
                    ? appState.selectedSymptomsText
                    : "Khám định kỳ ban đầu.",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: GlassTheme.oceanBlue, size: 20),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GlassTheme.bodyMd().copyWith(fontWeight: FontWeight.bold, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
