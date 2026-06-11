import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../services/database_service.dart';
import '../../widgets/glass_widgets.dart';
import '../splash_screen.dart';
import '../login_screen.dart';
import '../account/account_management_screen.dart';

/// Tab-embedded version of the appointment booking screen.
/// Used as a persistent tab in the patient's bottom navigation.
/// Pre-fills data from AI chatbot assessment when [AppState.pendingBookingFromAI] is true.
class AppointmentBookingTab extends StatefulWidget {
  const AppointmentBookingTab({super.key});

  @override
  State<AppointmentBookingTab> createState() => _AppointmentBookingTabState();
}

class _AppointmentBookingTabState extends State<AppointmentBookingTab> {
  int _activeStep = 0;

  // Selected data
  String _selectedType = "Trực tiếp";
  String _selectedBranch = "Bệnh viện Đa Khoa Trung Ương";
  String _selectedSpecialty = "Khoa Tim mạch";
  String _selectedDoctor = "BS. Nguyễn Văn An";
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedSlot = "09:00 - 09:30";

  // Additional patient info for booking
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _symptomsController;
  final TextEditingController _noteController = TextEditingController();

  List<String> get _branches {
    return DatabaseService.instance.doctors.map((e) => e.branch).toSet().toList();
  }

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
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _symptomsController = TextEditingController();
    
    _autoAssignSpecialtyAndDoctor();
    _prefillFromAI();

    AppState.instance.addListener(_onAppStateChanged);

    // Listen for the AI trigger after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAITrigger();
    });
  }

  @override
  void dispose() {
    AppState.instance.removeListener(_onAppStateChanged);
    _nameController.dispose();
    _phoneController.dispose();
    _symptomsController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    final appState = AppState.instance;
    if (appState.pendingBookingFromAI) {
      setState(() {
        _prefillFromAI();
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        appState.consumeBookingTrigger();
      });
    }
  }

  void _checkAITrigger() {
    final appState = AppState.instance;
    if (appState.pendingBookingFromAI) {
      _prefillFromAI();
      // Scroll to top to show the AI banner
      appState.consumeBookingTrigger();
    }
  }

  void _prefillFromAI() {
    final appState = AppState.instance;
    if (appState.selectedSymptomsText.isNotEmpty) {
      _symptomsController.text = appState.selectedSymptomsText;
      _noteController.text = "Cần tư vấn và theo dõi thêm.";
    }
    _autoAssignSpecialtyAndDoctor();
  }

  void _autoAssignSpecialtyAndDoctor() {
    final appState = AppState.instance;
    final symptomsText = appState.selectedSymptomsText.toLowerCase();

    if (symptomsText.contains("ngực") ||
        symptomsText.contains("tim") ||
        symptomsText.contains("mạch")) {
      _selectedSpecialty = "Khoa Tim mạch";
      _selectedDoctor = "BS. Nguyễn Văn An";
    } else if (symptomsText.contains("đầu") ||
        symptomsText.contains("não") ||
        symptomsText.contains("thần kinh")) {
      _selectedSpecialty = "Khoa Thần kinh";
      _selectedDoctor = "BS. Trần Quốc Đạt";
    } else if (symptomsText.contains("nhi") ||
        symptomsText.contains("bé") ||
        symptomsText.contains("trẻ")) {
      _selectedSpecialty = "Khoa Nhi";
      _selectedDoctor = "BS. Phạm Minh Tuấn";
    } else if (symptomsText.contains("ho") ||
        symptomsText.contains("phổi") ||
        symptomsText.contains("hô hấp")) {
      _selectedSpecialty = "Khoa Hô hấp";
      _selectedDoctor = "BS. Lê Thị Bình";
    } else {
      _selectedSpecialty = "Khoa Nội tổng quát";
      _selectedDoctor = "BS. Lê Thị Bình";
    }
  }

  List<DateTime> _getBookingDates() {
    return List.generate(
        7, (idx) => DateTime.now().add(Duration(days: idx + 1)));
  }

  String _getWeekdayVi(int day) {
    switch (day) {
      case 1:
        return "T2";
      case 2:
        return "T3";
      case 3:
        return "T4";
      case 4:
        return "T5";
      case 5:
        return "T6";
      case 6:
        return "T7";
      default:
        return "CN";
    }
  }

  void _nextStep() {
    if (_activeStep == 0) {
      if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền Họ tên và Số điện thoại (bắt buộc).')),
        );
        return;
      }
    }
    if (_activeStep == 2 && AppState.instance.selectedSymptomsText.isEmpty) {
      if (_symptomsController.text.trim().isEmpty || _noteController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng điền Mô tả tình trạng và Ghi chú (bắt buộc).')),
        );
        return;
      }
    }
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

  void _resetForm() {
    setState(() {
      _activeStep = 0;
      _selectedType = "Trực tiếp";
      _selectedBranch = "Bệnh viện Đa Khoa Trung Ương";
      _selectedDate = DateTime.now().add(const Duration(days: 1));
      _selectedSlot = "09:00 - 09:30";
      _symptomsController.clear();
      _noteController.clear();
    });
    AppState.instance.clearBookingData();
    _autoAssignSpecialtyAndDoctor();
  }

  void _finalizeBooking() {
    final appState = AppState.instance;
    final profile = appState.currentUserProfile;

    final finalBranch = _selectedType == "Trực tuyến"
        ? "Phòng khám A - Trực tuyến"
        : _selectedBranch;

    final defaultName = (profile != null && profile.name.isNotEmpty) 
        ? profile.name 
        : "Bệnh nhân";

    appState.bookAppointment(
      patientName: _nameController.text.trim().isNotEmpty
          ? _nameController.text.trim()
          : defaultName,
      branch: finalBranch,
      doctor: "Sẽ phân bổ sau",
      specialty: _selectedSpecialty,
      date: _selectedDate,
      slot: _selectedSlot,
      symptoms: "${_symptomsController.text.trim()}${_noteController.text.trim().isNotEmpty ? '\n\nGhi chú: ${_noteController.text.trim()}' : ''}",
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
              // Success icon with pulse animation
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.green.withValues(alpha: 0.12),
                        border: Border.all(color: Colors.green, width: 2.5),
                      ),
                      child: const Icon(Icons.check_circle,
                          color: Colors.green, size: 48),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Text(
                "Đặt Lịch Thành Công!",
                style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _selectedType == "Trực tuyến"
                    ? "Lịch tư vấn trực tuyến\nđã được xác nhận."
                    : "Lịch hẹn tại $_selectedBranch\nđã được xác nhận.",
                style: GlassTheme.bodyMd(),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: GlassTheme.oceanBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year} • $_selectedSlot",
                      style: GlassTheme.bodyMd(color: GlassTheme.oceanBlue)
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      "Mã lịch hẹn: ${appState.appointments.isNotEmpty ? appState.appointments.first.id : 'APT-XXXX'}",
                      style: GlassTheme.labelCaps(color: GlassTheme.outline),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: "Hoàn tất",
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        _resetForm();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return Scaffold(
      appBar: const GlassAppBar(
        title: "Đặt lịch khám",
        automaticallyImplyLeading: false,
      ),
      body: ListenableBuilder(
        listenable: appState,
        builder: (context, child) {
          final hasSymptoms = appState.selectedSymptomsText.isNotEmpty;

          if (!appState.isAuthenticated) {
            return GlassBackground(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: GlassCard(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.login, size: 64, color: GlassTheme.oceanBlue),
                        const SizedBox(height: 24),
                        Text(
                          "Yêu cầu Đăng Nhập",
                          style: GlassTheme.h2(color: GlassTheme.oceanBlue),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Bạn cần đăng nhập với tài khoản Bệnh nhân để sử dụng tính năng đặt lịch khám bệnh.",
                          textAlign: TextAlign.center,
                          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: GlassButton(
                            text: "Đăng Nhập",
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(
                                    expectedRole: UserRole.patient,
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
              ),
            );
          }

          return GlassBackground(
            child: Column(
              children: [
                // AI Recommendation Banner (shown when coming from chatbot)
                if (hasSymptoms) _buildAIBanner(appState),

                // Step Indicators
                _buildStepIndicator(),

                // Step Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: _buildStepContent(appState),
                  ),
                ),

                // Bottom Navigation Buttons
                _buildBottomButtons(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAIBanner(AppState appState) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GlassCard(
        borderColor: GlassTheme.cyan,
        borderWidth: 1.5,
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlassTheme.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: GlassTheme.oceanBlue, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "AI Khuyến Nghị Đặt Lịch",
                        style: GlassTheme.h3(color: GlassTheme.oceanBlue)
                            .copyWith(
                                fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 8),
                      _buildRiskBadge(appState.currentRiskLevel),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    appState.selectedSymptomsText,
                    style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                        .copyWith(fontSize: 12, height: 1.3),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.medical_services_outlined,
                          size: 14, color: GlassTheme.oceanBlue),
                      const SizedBox(width: 6),
                      Text(
                        "Chuyên khoa gợi ý: $_selectedSpecialty",
                        style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)
                            .copyWith(fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge(String risk) {
    Color badgeColor;
    switch (risk) {
      case "Khẩn cấp":
        badgeColor = GlassTheme.error;
        break;
      case "Cao":
        badgeColor = Colors.orange[800]!;
        break;
      case "Trung bình":
        badgeColor = GlassTheme.oceanBlue;
        break;
      default:
        badgeColor = Colors.green;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        risk,
        style: GlassTheme.labelCaps(color: badgeColor).copyWith(fontSize: 9),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final stepLabels = ["Hình thức", "Thời gian", "Xác nhận"];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      color: Colors.white.withValues(alpha: 0.3),
      child: Row(
        children: List.generate(3, (idx) {
          final active = _activeStep == idx;
          final done = _activeStep > idx;
          return Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Step circle
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: active
                        ? GlassTheme.oceanBlue
                        : (done
                            ? Colors.green
                            : Colors.white.withValues(alpha: 0.6)),
                    border: Border.all(
                      color: active
                          ? GlassTheme.oceanBlue
                          : (done
                              ? Colors.green
                              : GlassTheme.outline.withValues(alpha: 0.4)),
                      width: 2,
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                                color:
                                    GlassTheme.oceanBlue.withValues(alpha: 0.3),
                                blurRadius: 8)
                          ]
                        : [],
                  ),
                  child: Center(
                    child: done
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : Text(
                            "${idx + 1}",
                            style: GlassTheme.labelCaps(
                              color: active
                                  ? Colors.white
                                  : GlassTheme.onSurfaceVariant,
                            ).copyWith(fontSize: 12),
                          ),
                  ),
                ),
                const SizedBox(width: 6),
                // Step label
                Text(
                  stepLabels[idx],
                  style: GlassTheme.labelCaps(
                    color: active
                        ? GlassTheme.oceanBlue
                        : (done ? Colors.green : GlassTheme.outline),
                  ).copyWith(fontSize: 10),
                ),
                // Connector line
                if (idx < 2) ...[
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        color: done
                            ? Colors.green.withValues(alpha: 0.5)
                            : Colors.white30,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent(AppState appState) {
    switch (_activeStep) {
      case 0:
        return _buildTypeAndBranchStep(appState);
      case 1:
        return _buildDateTimeStep(appState);
      default:
        return _buildConfirmStep(appState);
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 1: Choose type & branch
  // ═══════════════════════════════════════════════════════════════
  Widget _buildTypeAndBranchStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.local_hospital,
                  color: GlassTheme.oceanBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "Chọn hình thức khám",
              style: GlassTheme.h3()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Bạn muốn khám trực tiếp tại phòng khám hay tư vấn video từ xa?",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        // Type cards
        Row(
          children: [
            // Online
            Expanded(
              child: _buildTypeCard(
                icon: Icons.video_call,
                title: "Tư Vấn\nTrực Tuyến",
                subtitle: "Video Call từ xa",
                isSelected: _selectedType == "Trực tuyến",
                onTap: () => setState(() {
                  _selectedType = "Trực tuyến";
                  _selectedBranch = "Phòng khám A - Trực tuyến";
                }),
              ),
            ),
            const SizedBox(width: 12),
            // Offline
            Expanded(
              child: _buildTypeCard(
                icon: Icons.local_hospital,
                title: "Khám Tại\nCơ Sở",
                subtitle: "Đến phòng khám",
                isSelected: _selectedType == "Trực tiếp",
                onTap: () => setState(() {
                  _selectedType = "Trực tiếp";
                  _selectedBranch = "Bệnh viện Đa Khoa Trung Ương";
                }),
              ),
            ),
          ],
        ),

        const SizedBox(height: 28),

        // Branch selection (only for in-person)
        if (_selectedType == "Trực tiếp") ...[
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.location_on,
                    color: GlassTheme.oceanBlue, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                "Chọn chi nhánh phòng khám",
                style: GlassTheme.h3()
                    .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._branches.map((br) {
            final isSel = _selectedBranch == br;
            final parts = br.split(" - ");
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => setState(() => _selectedBranch = br),
                borderRadius: BorderRadius.circular(16),
                child: GlassCard(
                  borderColor: isSel ? GlassTheme.cyan : Colors.white,
                  borderWidth: isSel ? 2 : 1,
                  opacity: isSel ? 0.8 : 0.55,
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color:
                              isSel ? GlassTheme.oceanBlue : Colors.transparent,
                          border: Border.all(
                            color: isSel
                                ? GlassTheme.oceanBlue
                                : GlassTheme.outline.withValues(alpha: 0.5),
                            width: 2,
                          ),
                        ),
                        child: isSel
                            ? const Icon(Icons.check,
                                size: 14, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              parts.first,
                              style: GlassTheme.h3().copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isSel
                                    ? GlassTheme.oceanBlue
                                    : GlassTheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              parts.length > 1
                                  ? parts.sublist(1).join(" - ")
                                  : "",
                              style: GlassTheme.bodyMd(
                                      color: GlassTheme.onSurfaceVariant)
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.location_on,
                        color: isSel
                            ? GlassTheme.oceanBlue
                            : GlassTheme.outline.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ] else ...[
          // Online consultation info card
          GlassCard(
            borderColor: GlassTheme.cyan.withValues(alpha: 0.4),
            borderWidth: 1.2,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline,
                    color: GlassTheme.oceanBlue, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Tư vấn trực tuyến qua video",
                        style: GlassTheme.h3().copyWith(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Kết nối nhanh với bác sĩ chuyên khoa qua Video Call. Không giới hạn địa lý, phù hợp cho tư vấn ban đầu dựa trên hồ sơ triệu chứng AI của bạn.",
                        style: GlassTheme.bodyMd(
                                color: GlassTheme.onSurfaceVariant)
                            .copyWith(fontSize: 12, height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Patient info section
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline,
                  color: GlassTheme.oceanBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "Thông tin người khám",
              style: GlassTheme.h3()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildInfoField(
                controller: _nameController,
                label: "Họ và tên *",
                icon: Icons.person,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildInfoField(
                controller: _phoneController,
                label: "Số điện thoại *",
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: isSelected
              ? GlassTheme.oceanBlue.withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? GlassTheme.cyan
                : Colors.white.withValues(alpha: 0.6),
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? GlassTheme.oceanBlue.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? GlassTheme.oceanBlue : GlassTheme.outline,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GlassTheme.h3().copyWith(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? GlassTheme.oceanBlue : GlassTheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
                  .copyWith(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      opacity: 0.5,
      borderColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)
                  .copyWith(fontSize: 9)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(icon, size: 16, color: GlassTheme.oceanBlue),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: GlassTheme.bodyMd().copyWith(fontSize: 13),
                  keyboardType: keyboardType,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 2: Choose date & time
  // ═══════════════════════════════════════════════════════════════
  Widget _buildDateTimeStep(AppState appState) {
    final dates = _getBookingDates();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date section
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.calendar_today,
                  color: GlassTheme.oceanBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "Chọn ngày khám",
              style: GlassTheme.h3()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GlassCard(
          padding: const EdgeInsets.all(0),
          borderColor: GlassTheme.cyan.withValues(alpha: 0.3),
          child: CalendarDatePicker(
            initialDate: _selectedDate,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
            onDateChanged: (date) {
              setState(() {
                _selectedDate = date;
              });
            },
          ),
        ),

        const SizedBox(height: 28),

        // Time section
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.access_time,
                  color: GlassTheme.oceanBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "Chọn khung giờ",
              style: GlassTheme.h3()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          "Các khung giờ còn trống tại ${_selectedType == "Trực tuyến" ? "phòng khám trực tuyến" : _selectedBranch.split(" - ").first}",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant)
              .copyWith(fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _timeSlots.map((slot) {
            final isSel = _selectedSlot == slot;
            return InkWell(
              onTap: () => setState(() => _selectedSlot = slot),
              borderRadius: BorderRadius.circular(14),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: isSel
                      ? GlassTheme.oceanBlue
                      : Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSel
                        ? GlassTheme.oceanBlue
                        : Colors.white.withValues(alpha: 0.7),
                    width: isSel ? 2 : 1,
                  ),
                  boxShadow: isSel
                      ? [
                          BoxShadow(
                              color:
                                  GlassTheme.oceanBlue.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2))
                        ]
                      : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: isSel ? Colors.white : GlassTheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      slot,
                      style: GlassTheme.bodyMd(
                        color: isSel ? Colors.white : GlassTheme.onSurface,
                      ).copyWith(
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // STEP 3: Review & confirm
  // ═══════════════════════════════════════════════════════════════
  Widget _buildConfirmStep(AppState appState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.assignment_turned_in,
                  color: GlassTheme.oceanBlue, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              "Xác nhận thông tin đặt lịch",
              style: GlassTheme.h3()
                  .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          "Vui lòng kiểm tra kỹ thông tin trước khi xác nhận.",
          style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
        ),
        const SizedBox(height: 20),

        // Main confirmation card
        GlassCard(
          borderColor: GlassTheme.cyan,
          borderWidth: 1.5,
          child: Column(
            children: [
              // Patient info
              _buildConfirmRow(
                Icons.person,
                "Người khám",
                _nameController.text.trim().isNotEmpty
                    ? _nameController.text.trim()
                    : "Nguyễn Minh Anh",
              ),
              const Divider(color: Colors.white30, height: 20),
              _buildConfirmRow(
                Icons.phone_android,
                "Số điện thoại",
                _phoneController.text.trim().isNotEmpty
                    ? _phoneController.text.trim()
                    : "0912 345 678",
              ),
              const Divider(color: Colors.white30, height: 20),

              // Type
              _buildConfirmRow(
                _selectedType == "Trực tuyến"
                    ? Icons.video_call
                    : Icons.local_hospital,
                "Hình thức",
                _selectedType == "Trực tuyến"
                    ? "Tư vấn trực tuyến qua Video Call"
                    : "Khám trực tiếp tại cơ sở",
              ),
              const Divider(color: Colors.white30, height: 20),

              // Branch
              _buildConfirmRow(
                Icons.location_on,
                "Địa điểm",
                _selectedType == "Trực tuyến"
                    ? "Phòng khám Trực tuyến"
                    : _selectedBranch,
              ),
              const Divider(color: Colors.white30, height: 20),


              // Date & Time
              _buildConfirmRow(
                Icons.calendar_today,
                "Thời gian khám",
                "${_getWeekdayVi(_selectedDate.weekday)}, ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}\nGiờ: $_selectedSlot",
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Symptoms note card
        // Symptoms note card
        GlassCard(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          opacity: 0.45,
          borderColor: Colors.amber.withValues(alpha: 0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    appState.selectedSymptomsText.isNotEmpty
                        ? "Mô tả tình trạng / Triệu chứng"
                        : "Mô tả tình trạng / Triệu chứng *",
                    style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)
                        .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  if (appState.selectedSymptomsText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GlassTheme.oceanBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology, size: 10, color: GlassTheme.oceanBlue),
                          const SizedBox(width: 4),
                          Text(
                            "AI tự điền",
                            style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)
                                .copyWith(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _symptomsController,
                style: GlassTheme.bodyMd().copyWith(fontSize: 13),
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Ví dụ: Sốt cao, đau đầu...",
                  hintStyle: TextStyle(color: GlassTheme.outline, fontSize: 12),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Additional note field
        GlassCard(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          opacity: 0.45,
          borderColor: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    appState.selectedSymptomsText.isNotEmpty
                        ? "Ghi chú thêm (tuỳ chọn)"
                        : "Ghi chú thêm *",
                    style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)
                        .copyWith(fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  if (appState.selectedSymptomsText.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: GlassTheme.oceanBlue.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology, size: 10, color: GlassTheme.oceanBlue),
                          const SizedBox(width: 4),
                          Text(
                            "AI tự điền",
                            style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)
                                .copyWith(fontSize: 8),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _noteController,
                style: GlassTheme.bodyMd().copyWith(fontSize: 13),
                maxLines: 2,
                decoration: const InputDecoration(
                  hintText: "Ví dụ: yêu cầu đặc biệt, tiền sử bệnh...",
                  hintStyle: TextStyle(color: GlassTheme.outline, fontSize: 12),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmRow(IconData icon, String title, String value) {
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
                style: GlassTheme.labelCaps(color: GlassTheme.onSurfaceVariant)
                    .copyWith(fontSize: 10),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GlassTheme.bodyMd()
                    .copyWith(fontWeight: FontWeight.w600, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // Bottom navigation buttons
  // ═══════════════════════════════════════════════════════════════
  Widget _buildBottomButtons() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      child: Row(
        children: [
          if (_activeStep > 0) ...[
            Expanded(
              child: GlassButton(
                text: "Quay lại",
                isPrimary: false,
                height: 50,
                onPressed: _prevStep,
              ),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            flex: _activeStep == 2 ? 2 : 1,
            child: GlassButton(
              text: _activeStep == 2 ? "✓  Xác nhận đặt lịch" : "Tiếp theo →",
              height: 50,
              onPressed: _nextStep,
            ),
          ),
        ],
      ),
      ),
    );
  }
}
