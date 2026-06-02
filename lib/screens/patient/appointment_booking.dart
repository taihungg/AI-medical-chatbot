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
  String _selectedType = "Trực tiếp"; // Trực tiếp | Trực tuyến
  String _selectedBranch = "Phòng khám A - Quận 1, TP. HCM";
  String _selectedSpecialty = "Khoa Nội tổng quát";
  String _selectedDoctor = "BS. Lê Thị Bình";
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = "09:00 - 09:30";

  final List<String> _branches = [
    "Phòng khám A - Quận 1, TP. HCM",
    "Phòng khám B - Hoàn Kiếm, Hà Nội",
    "Phòng khám C - Hải Châu, Đà Nẵng",
    "Phòng khám D - Ninh Kiều, Cần Thơ"
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

  @override
  void initState() {
    super.initState();
    _autoAssignSpecialtyAndDoctor();
  }

  void _autoAssignSpecialtyAndDoctor() {
    final appState = AppState.instance;
    final symptomsText = appState.selectedSymptomsText.toLowerCase();
    
    if (symptomsText.contains("ngực") || symptomsText.contains("tim")) {
      _selectedSpecialty = "Khoa Tim mạch";
      _selectedDoctor = "BS. Nguyễn Văn An";
    } else if (symptomsText.contains("đầu") || symptomsText.contains("não") || symptomsText.contains("thần kinh")) {
      _selectedSpecialty = "Khoa Thần kinh";
      _selectedDoctor = "BS. Trần Quốc Đạt";
    } else if (symptomsText.contains("nhi") || symptomsText.contains("bé") || symptomsText.contains("trẻ")) {
      _selectedSpecialty = "Khoa Nhi";
      _selectedDoctor = "BS. Phạm Minh Tuấn";
    } else {
      _selectedSpecialty = "Khoa Nội tổng quát";
      _selectedDoctor = "BS. Lê Thị Bình";
    }
  }

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
    if (_activeStep < 2) {
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

    final finalBranch = _selectedType == "Trực tuyến"
        ? "Phòng khám A - Trực tuyến"
        : _selectedBranch;

    appState.bookAppointment(
      patientName: "Nguyễn Minh Anh",
      branch: finalBranch,
      doctor: _selectedDoctor,
      specialty: _selectedSpecialty,
      date: _selectedDate,
      slot: _selectedSlot,
      symptoms: appState.selectedSymptomsText.isNotEmpty
          ? appState.selectedSymptomsText
          : "Đăng ký tư vấn y tế ban đầu.",
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
                _selectedType == "Trực tuyến"
                    ? "Lịch tư vấn trực tuyến chuyên khoa với $_selectedDoctor đã được thiết lập."
                    : "Lịch hẹn khám tại $_selectedBranch với $_selectedDoctor đã được thiết lập.",
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
        title: "Đặt Lịch Khám Y Khoa",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GlassTheme.oceanBlue),
          onPressed: _activeStep > 0 ? _prevStep : () => Navigator.of(context).pop(),
        ),
      ),
      body: GlassBackground(
        child: Column(
          children: [
            // Horizontal Step Indicators (3 Steps)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: Colors.white.withOpacity(0.3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(3, (idx) {
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
                      if (idx < 2)
                        Container(
                          width: 80,
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
                      text: _activeStep == 2 ? "Xác nhận đặt lịch" : "Tiếp theo",
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
        return _buildTypeAndBranchSelection();
      case 1:
        return _buildDateTimeSelection();
      default:
        return _buildReviewConfirmation();
    }
  }

  Widget _buildTypeAndBranchSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BƯỚC 1: CHỌN HÌNH THỨC & CƠ SỞ KHÁM", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
        const SizedBox(height: 12),
        Text(
          "Chọn tư vấn trực tuyến qua Video Call từ xa hoặc khám trực tiếp tại cơ sở phòng khám.",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 24),
        
        // Online vs Offline Row
        Row(
          children: [
            // Online Card
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedType = "Trực tuyến";
                    _selectedBranch = "Phòng khám A - Trực tuyến";
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: GlassCard(
                  borderColor: _selectedType == "Trực tuyến" ? GlassTheme.cyan : Colors.white30,
                  borderWidth: _selectedType == "Trực tuyến" ? 2 : 1,
                  opacity: _selectedType == "Trực tuyến" ? 0.8 : 0.45,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.video_call,
                        color: _selectedType == "Trực tuyến" ? GlassTheme.oceanBlue : GlassTheme.outline,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Tư Vấn Trực Tuyến",
                        style: GlassTheme.h3().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedType == "Trực tuyến" ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Video Call từ xa",
                        style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Offline Card
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedType = "Trực tiếp";
                    _selectedBranch = "Phòng khám A - Quận 1, TP. HCM";
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: GlassCard(
                  borderColor: _selectedType == "Trực tiếp" ? GlassTheme.cyan : Colors.white30,
                  borderWidth: _selectedType == "Trực tiếp" ? 2 : 1,
                  opacity: _selectedType == "Trực tiếp" ? 0.8 : 0.45,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.local_hospital,
                        color: _selectedType == "Trực tiếp" ? GlassTheme.oceanBlue : GlassTheme.outline,
                        size: 36,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Khám Tại Cơ Sở",
                        style: GlassTheme.h3().copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: _selectedType == "Trực tiếp" ? GlassTheme.oceanBlue : GlassTheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Đến trực tiếp phòng khám",
                        style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 32),
        
        // Show Branch selector only if Offline is selected
        if (_selectedType == "Trực tiếp") ...[
          Text("CHỌN CHI NHÁNH PHÒNG KHÁM:", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue).copyWith(fontSize: 11)),
          const SizedBox(height: 12),
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
        ] else ...[
          // Informative card for Online Consultation
          GlassCard(
            borderColor: GlassTheme.cyan.withOpacity(0.4),
            borderWidth: 1.2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info, color: GlassTheme.oceanBlue, size: 24),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Thông tin hình thức trực tuyến",
                        style: GlassTheme.h3().copyWith(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Lịch tư vấn video trực tiếp từ xa sẽ giúp bạn kết nối nhanh với bác sĩ chuyên khoa. Trực tuyến không bị giới hạn địa lý và phù hợp nhất cho tư vấn ban đầu dựa trên hồ sơ triệu chứng AI của bạn.",
                        style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDateTimeSelection() {
    final dates = _getBookingDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("BƯỚC 2: CHỌN NGÀY & KHUNG GIỜ KHÁM", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
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
        Text("BƯỚC 3: RÀ SOÁT LỊCH HẸN Y KHOA", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
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
              // Type Info
              _buildReviewRow(Icons.video_call_outlined, "Hình thức tư vấn", _selectedType),
              const Divider(color: Colors.white30, height: 24),
              // Branch info
              _buildReviewRow(
                Icons.location_on, 
                "Cơ sở điều trị", 
                _selectedType == "Trực tuyến" ? "Khám tư vấn từ xa qua Video Call" : _selectedBranch
              ),
              const Divider(color: Colors.white38, height: 24),
              // Specialty & Auto-assigned Doctor info
              _buildReviewRow(
                Icons.medical_services_outlined, 
                "Bác sĩ & Chuyên khoa", 
                "Chuyên gia phù hợp nhất sẽ được hệ thống phân bổ tự động dựa trên triệu chứng AI.\n(Chuyên khoa dự kiến: $_selectedSpecialty)"
              ),
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
