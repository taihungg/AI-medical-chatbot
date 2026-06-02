import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../splash_screen.dart';
import '../patient/doctor_consultation.dart';

class DoctorSpecialistDashboard extends StatefulWidget {
  const DoctorSpecialistDashboard({super.key});

  @override
  State<DoctorSpecialistDashboard> createState() => _DoctorSpecialistDashboardState();
}

class _DoctorSpecialistDashboardState extends State<DoctorSpecialistDashboard> {
  static const String _doctorName = "BS. Nguyễn Văn An";
  String _selectedFilter = 'Tất cả'; // Tất cả, Chưa khám, Đã khám
  AppAppointment? _selectedAppointment;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 700;

        // Filter appointments
        final filteredAppointments = appState.appointments.where((appt) {
          if (_selectedFilter == 'Tất cả') return true;
          return appt.status == _selectedFilter;
        }).toList();


        return Scaffold(
          appBar: GlassAppBar(
            title: isMobile ? "Bác Sĩ" : "Cổng Thông Tin Bác Sĩ",
            actions: [
              PopupMenuButton<String>(
                offset: const Offset(0, 40),
                tooltip: "Menu Bác sĩ",
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const SplashScreen()),
                    );
                  } else if (value == 'toggle_busy') {
                    appState.toggleDoctorBusy();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'info',
                    enabled: false,
                    child: Text(
                      _doctorName,
                      style: GlassTheme.bodyLg().copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'dashboard',
                    child: const Row(
                      children: [
                        Icon(Icons.dashboard_outlined, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text("Dashboard"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'appointments',
                    child: const Row(
                      children: [
                        Icon(Icons.calendar_month_outlined, size: 20, color: Colors.black54),
                        SizedBox(width: 12),
                        Text("Ca Khám"),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'toggle_busy',
                    child: StatefulBuilder(
                      builder: (context, setPopupState) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.do_not_disturb_on_outlined, size: 20, color: Colors.black54),
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
                              activeColor: Colors.red,
                            ),
                          ],
                        );
                      }
                    ),
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
                        backgroundColor: appState.isDoctorBusy ? Colors.red : GlassTheme.oceanBlue,
                        child: const Icon(Icons.person_pin, color: Colors.white, size: 20),
                      ),
                      if (!isMobile) ...[
                        const SizedBox(width: 8),
                        Text(
                          _doctorName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: appState.isDoctorBusy ? Colors.red : null,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: GlassBackground(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN: Queue & Filters (occupies 1/3 if wide screen, full width if mobile)
                if (!isMobile || _selectedAppointment == null)
                  Expanded(
                    flex: isMobile ? 1 : 12,
                    child: ListView(
                    padding: const EdgeInsets.all(16.0),
                    children: [
                      // 1. Stats Bento cards
                      Row(
                        children: [
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("CHƯA KHÁM", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${appState.appointments.where((a) => a.status == 'Chưa khám').length} ca",
                                    style: GlassTheme.h1(color: GlassTheme.oceanBlue).copyWith(fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GlassCard(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ĐÃ KHÁM", style: GlassTheme.labelCaps(color: Colors.green)),
                                  const SizedBox(height: 6),
                                  Text(
                                    "${appState.appointments.where((a) => a.status == 'Đã khám').length} ca",
                                    style: GlassTheme.h1(color: Colors.green).copyWith(fontSize: 24),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // 2. Queue Section Title & Filters
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Hàng Đợi Hôm Nay", style: GlassTheme.h2()),
                          // Active count indicator
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              "${filteredAppointments.length} Ca",
                              style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue).copyWith(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Choice chip filter layout
                      Row(
                        children: ['Tất cả', 'Chưa khám', 'Đã khám'].map((filter) {
                          final isSelected = _selectedFilter == filter;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedFilter = filter;
                                });
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? GlassTheme.primaryGradient : null,
                                  color: isSelected ? null : Colors.white.withOpacity(0.4),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : Colors.white38,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: GlassTheme.bodyMd(
                                    color: isSelected ? Colors.white : GlassTheme.onSurfaceVariant,
                                  ).copyWith(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // 3. Queue List
                      if (filteredAppointments.isEmpty)
                        const GlassCard(
                          height: 180,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.fact_check_outlined, size: 40, color: GlassTheme.outline),
                                SizedBox(height: 10),
                                Text(
                                  "Hàng đợi rỗng trong bộ lọc này",
                                  style: TextStyle(color: GlassTheme.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ...filteredAppointments.map((appt) {
                          final isSelected = _selectedAppointment?.id == appt.id;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _selectedAppointment = appt;
                                });
                                // Automatically open full consult if tapped and screens allow
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: GlassCard(
                                padding: const EdgeInsets.all(16),
                                borderColor: isSelected ? GlassTheme.oceanBlue : Colors.white,
                                borderWidth: isSelected ? 1.8 : 1.0,
                                opacity: isSelected ? 0.8 : 0.6,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          appt.id,
                                          style: GlassTheme.labelCaps(color: GlassTheme.outline),
                                        ),
                                        StatusBadge(status: appt.status),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(appt.patientName, style: GlassTheme.h3()),
                                    const SizedBox(height: 4),
                                    Text(
                                      "${appt.specialty} • ${appt.timeSlot}",
                                      style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Triệu chứng: ${appt.symptomSummary}",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GlassTheme.bodyMd(color: GlassTheme.onSurfaceVariant).copyWith(fontSize: 12),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Icon(Icons.favorite, color: Colors.pink, size: 14),
                                            const SizedBox(width: 4),
                                            Text(
                                              "${appt.vitals['pulse']?.toInt()} bpm",
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.pink),
                                            ),
                                          ],
                                        ),
                                        // Action indicator
                                        Row(
                                          children: [
                                            Text(
                                              appt.status == 'Hoàn thành' ? "Đã duyệt" : "Xem hồ sơ",
                                              style: GlassTheme.labelCaps(
                                                color: appt.status == 'Hoàn thành' ? Colors.green : GlassTheme.oceanBlue,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Icon(
                                              appt.status == 'Hoàn thành' ? Icons.check : Icons.arrow_forward_ios,
                                              size: 12,
                                              color: appt.status == 'Hoàn thành' ? Colors.green : GlassTheme.oceanBlue,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),

                // RIGHT SIDEBAR / CLINICAL WORKSPACE (Shows patient details and acts as workspace)
                if (_selectedAppointment != null)
                  Expanded(
                    flex: isMobile ? 1 : 18,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isMobile ? Colors.transparent : Colors.white.withOpacity(0.4),
                            width: isMobile ? 0 : 1,
                          ),
                        ),
                      ),
                      child: ClinicalWorkspace(
                        appointmentId: _selectedAppointment!.id,
                        onClosed: () {
                          setState(() {
                            _selectedAppointment = null;
                          });
                        },
                      ),
                    ),
                  )
                else if (!isMobile)
                  const Expanded(
                    flex: 18,
                    child: Center(
                      child: GlassCard(
                        width: 320,
                        margin: EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.assignment_ind_outlined, size: 48, color: GlassTheme.oceanBlue),
                            SizedBox(height: 16),
                            Text(
                              "Chưa Chọn Ca Khám",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Vui lòng chọn một bệnh nhân từ hàng đợi bên trái để bắt đầu cuộc tư vấn, xem sinh hiệu và lập bệnh án lâm sàng.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: GlassTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }



}

// Workspace inside right panel for managing live consults
class ClinicalWorkspace extends StatefulWidget {
  final String appointmentId;
  final VoidCallback onClosed;

  const ClinicalWorkspace({
    super.key,
    required this.appointmentId,
    required this.onClosed,
  });

  @override
  State<ClinicalWorkspace> createState() => _ClinicalWorkspaceState();
}

class _ClinicalWorkspaceState extends State<ClinicalWorkspace> {
  final TextEditingController _notesController = TextEditingController();
  final List<String> _medications = [];
  final TextEditingController _customMedController = TextEditingController();
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _loadAppointmentData();
  }

  @override
  void didUpdateWidget(ClinicalWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appointmentId != widget.appointmentId) {
      _loadAppointmentData();
    }
  }

  void _loadAppointmentData() {
    final appState = AppState.instance;
    final appt = appState.appointments.firstWhere(
      (a) => a.id == widget.appointmentId,
      orElse: () => AppAppointment(
        id: '',
        patientName: 'Lỗi Dữ Liệu',
        branchName: '',
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now(),
        timeSlot: '',
        symptomSummary: '',
        riskLevel: 'Thấp',
      ),
    );
    _notesController.text = appt.clinicalNotes;
    _medications.clear();
    _medications.addAll(appt.prescriptionList);
    _stopRecordingSim();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _customMedController.dispose();
    super.dispose();
  }

  void _stopRecordingSim() {
    setState(() {
      _isRecording = false;
    });
  }

  // Dictate simulation waves & audio transcript
  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        // Output mock text on stop
        final mockTranscripts = [
          "Bệnh nhân có biểu hiện đau tức vùng xương ức trái, lan tỏa nhẹ ra bả vai trái khi làm việc nặng. Vitals cho thấy huyết áp tâm thu dao động ở mức 140 mmHg, nhịp tim hơi nhanh. Đề xuất: Điện tâm đồ (ECG) khẩn trương và lập phác đồ kiểm soát mạch ổn định.",
          "Triệu chứng ho khan từng cơn kéo dài trên 3 tuần, sốt nhẹ dao động 37.5 độ về chiều tối, lồng ngực gõ trong. Bác sĩ chỉ định chụp X-quang phổi thẳng để loại trừ tổn thương thực thể. Kê kháng sinh nhẹ và siro ho thảo dược.",
          "Cơn đau nửa đầu kiểu Migraine khởi phát dữ dội kèm theo buồn nôn, sợ tiếng động mạnh và ánh sáng. Khuyến cáo bệnh nhân nghỉ ngơi phòng tối, bổ sung Magie và sử dụng giảm đau thần kinh khi đau đỉnh điểm."
        ];
        // Pick one based on symptoms
        final appState = AppState.instance;
        final appt = appState.appointments.firstWhere(
          (a) => a.id == widget.appointmentId,
          orElse: () => AppAppointment(
            id: '',
            patientName: 'Lỗi Dữ Liệu',
            branchName: '',
            doctorName: '',
            specialty: '',
            dateTime: DateTime.now(),
            timeSlot: '',
            symptomSummary: '',
            riskLevel: 'Thấp',
          ),
        );
        String text = mockTranscripts[0];
        if (appt.symptomSummary.toLowerCase().contains("ho") || appt.symptomSummary.toLowerCase().contains("phổi")) {
          text = mockTranscripts[1];
        } else if (appt.symptomSummary.toLowerCase().contains("đầu") || appt.symptomSummary.toLowerCase().contains("thần kinh")) {
          text = mockTranscripts[2];
        }
        
        _notesController.text = (_notesController.text + " " + text).trim();
      });
    } else {
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _addMedication(String med) {
    if (med.trim().isEmpty) return;
    setState(() {
      _medications.add(med);
      _customMedController.clear();
    });
  }

  void _showDosageDialog(String medName) {
    final TextEditingController dosageController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Chỉnh sửa liều lượng", style: GlassTheme.h3().copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(medName, style: const TextStyle(fontWeight: FontWeight.bold, color: GlassTheme.oceanBlue)),
              const SizedBox(height: 16),
              GlassTextField(
                controller: dosageController,
                label: "",
                hint: "VD: Uống sau ăn, ngày 2 lần...",
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: "Hủy",
                      isPrimary: false,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      text: "Thêm",
                      onPressed: () {
                        final dosage = dosageController.text.trim();
                        if (dosage.isNotEmpty) {
                          _addMedication("$medName ($dosage)");
                        } else {
                          _addMedication(medName);
                        }
                        Navigator.of(ctx).pop();
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

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
  }

  void _saveSession() {
    final appState = AppState.instance;
    appState.saveConsultationNotes(widget.appointmentId, _notesController.text, _medications);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bản nháp bệnh án đã được lưu thành công!"),
        backgroundColor: GlassTheme.oceanBlue,
      ),
    );
  }

  void _showPublishConfirmation(BuildContext context) {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng ghi nhận chẩn đoán/kết luận trước khi ban hành."),
          backgroundColor: GlassTheme.error,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: GlassCard(
          borderColor: Colors.green,
          borderWidth: 1.5,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                "Xác Nhận Ban Hành",
                style: GlassTheme.h2(color: Colors.green),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bạn có chắc chắn muốn ban hành đơn thuốc này không?",
                style: TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      text: "Hủy",
                      isPrimary: false,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GlassButton(
                      text: "Đồng ý",
                      onPressed: () {
                        final appState = AppState.instance;
                        appState.saveConsultationNotes(widget.appointmentId, _notesController.text, _medications);
                        appState.signPrescription(widget.appointmentId);
                        
                        Navigator.of(ctx).pop(); // Close dialog
                        widget.onClosed(); // Close panel workspace
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Đơn thuốc đã được ban hành."),
                            backgroundColor: Colors.green,
                          ),
                        );
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



  Widget _buildReadOnlyBox(String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white38),
      ),
      child: Text(
        content,
        style: const TextStyle(fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildInlineStatus(String text, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final appt = appState.appointments.firstWhere((a) => a.id == widget.appointmentId);
    final isCompleted = appt.status == 'Đã khám';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Workspace Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              border: Border(bottom: BorderSide(color: Colors.white.withOpacity(0.4))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "WORKSPACE LÂM SÀNG",
                        style: GlassTheme.labelCaps(color: GlassTheme.outline),
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "${appt.patientName} (${appt.id})",
                              style: GlassTheme.h3().copyWith(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          StatusBadge(status: appt.status),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: GlassTheme.onSurfaceVariant),
                  onPressed: widget.onClosed,
                ),
              ],
            ),
          ),

          // Core workspace scroll area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. AI Summary Card (Tóm Tắt từ Chatbot)
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: GlassTheme.oceanBlue.withValues(alpha: 0.5),
                  opacity: 0.8,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: GlassTheme.oceanBlue.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.psychology,
                          color: GlassTheme.oceanBlue,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tóm Tắt Trợ Lý AI",
                              style: GlassTheme.h3(color: GlassTheme.oceanBlue).copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildReadOnlyBox(
                              appt.aiSummary.isEmpty
                                  ? "Bệnh nhân đăng ký khám trực tiếp, không sử dụng trợ lý AI."
                                  : appt.aiSummary,
                            ),
                            const SizedBox(height: 12),
                            if (isCompleted)
                              _buildInlineStatus(
                                "Ca đã hoàn tất, chỉ xem hồ sơ",
                                Colors.green,
                                Icons.lock_outline,
                              )
                            else
                              GlassButton(
                                text: appt.isOnline ? "Bắt Đầu Call Video" : "Bắt Đầu Khám",
                                width: 180,
                                height: 38,
                                onPressed: () {
                                  if (appt.isOnline) {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => DoctorConsultationScreen(appointment: appt),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Bắt đầu quy trình khám bệnh trực tiếp."),
                                        backgroundColor: GlassTheme.oceanBlue,
                                      ),
                                    );
                                  }
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Diagnosis & Speech dictation area
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Khám Bệnh & Chẩn Đoán", style: GlassTheme.h3().copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                          // Voice dictate button
                          _buildDictateButton(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Recording active wave simulator
                      if (_isRecording) const RecordingVisualizer(),

                      GlassTextField(
                        controller: _notesController,
                        label: "",
                        hint: "Nhập kết luận chẩn đoán lâm sàng của bác sĩ tại đây...",
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Smart Electronic Prescription Kê Đơn Thuốc
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kê Đơn Thuốc Điện Tử", style: GlassTheme.h3().copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      const Text(
                        "Thêm danh mục thuốc điều trị cùng liều lượng hướng dẫn.",
                        style: TextStyle(fontSize: 11, color: GlassTheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 12),

                      // Quick medicine selector presets chips
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            "Amlodipine 5mg (ngày 1v)",
                            "Panadol Extra 500mg (ngày 2v)",
                            "Nitroglycerin 0.5mg (uống khi đau thắt)",
                            "Siro ho Prospan (uống ngày 3 lần)",
                            "Amoxicillin 500mg (ngày 2v)"
                          ].map((preset) => Padding(
                            padding: const EdgeInsets.only(right: 6.0),
                            child: Tooltip(
                              message: preset,
                              child: ActionChip(
                                label: Text(preset.split("(")[0].trim(), style: const TextStyle(fontSize: 10)),
                                backgroundColor: Colors.white60,
                                onPressed: () => _showDosageDialog(preset.split("(")[0].trim()),
                              ),
                            ),
                          )).toList(),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Custom medicine text field
                      Row(
                        children: [
                          Expanded(
                            child: GlassTextField(
                              controller: _customMedController,
                              label: "",
                              hint: "Tên thuốc, hàm lượng, cách uống...",
                            ),
                          ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => _addMedication(_customMedController.text),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                gradient: GlassTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.add, color: Colors.white, size: 24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Medicine list output
                      if (_medications.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12.0),
                          child: Center(
                            child: Text(
                              "Chưa có thuốc nào được kê.",
                              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: GlassTheme.outline),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _medications.length,
                          itemBuilder: (ctx, idx) => Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white54,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.white),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.medication, color: GlassTheme.oceanBlue, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(_medications[idx], style: const TextStyle(fontSize: 12)),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: GlassTheme.error, size: 16),
                                  onPressed: () => _removeMedication(idx),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 5. Action Row buttons
                Row(
                  children: [
                    Expanded(
                      child: GlassButton(
                        text: "Lưu bản nháp",
                        isPrimary: false,
                        onPressed: _saveSession,
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (appt.status != 'Hoàn thành')
                      Expanded(
                        child: GlassButton(
                          text: "Ban Hành",
                          onPressed: () => _showPublishConfirmation(context),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDictateButton() {
    return InkWell(
      onTap: _toggleRecording,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isRecording ? GlassTheme.error.withOpacity(0.12) : GlassTheme.oceanBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isRecording ? GlassTheme.error : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.stop : Icons.mic,
              size: 14,
              color: _isRecording ? GlassTheme.error : GlassTheme.oceanBlue,
            ),
            const SizedBox(width: 6),
            Text(
              _isRecording ? "Dừng ghi AI" : "Ghi âm AI",
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: _isRecording ? GlassTheme.error : GlassTheme.oceanBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

}

class RecordingVisualizer extends StatefulWidget {
  const RecordingVisualizer({super.key});

  @override
  State<RecordingVisualizer> createState() => _RecordingVisualizerState();
}

class _RecordingVisualizerState extends State<RecordingVisualizer> {
  double _recordingSeconds = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _recordingSeconds += 0.1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
            const SizedBox(width: 8),
            Text(
              "Đang nghe giọng nói... ${_recordingSeconds.toStringAsFixed(1)}s",
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            const SizedBox(width: 12),
            // Simulated scrolling visualizer bars
            Expanded(
              child: SizedBox(
                height: 16,
                child: CustomPaint(
                  painter: RecordingWavePainter(seconds: _recordingSeconds),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Custom Painter for Dictation audio waveforms
class RecordingWavePainter extends CustomPainter {
  final double seconds;

  RecordingWavePainter({required this.seconds});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = GlassTheme.cyan
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final double midY = size.height / 2;
    final int barsCount = 20;
    final double barGap = size.width / (barsCount + 1);

    for (int i = 0; i < barsCount; i++) {
      final double x = (i + 1) * barGap;
      // Fluctuating height based on sine waves and random variations
      final double waveHeight = 2.0 + 8.0 * sin(seconds * 5 + i) * cos(seconds * 3 + i * 2).abs();
      canvas.drawLine(
        Offset(x, midY - waveHeight),
        Offset(x, midY + waveHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant RecordingWavePainter oldDelegate) => true;
}

class StatusBadge extends StatelessWidget {
  final String status;
  
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final bool isDone = status == 'Đã khám';
    final Color color = isDone ? Colors.green : GlassTheme.oceanBlue;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: GlassTheme.labelCaps(color: color).copyWith(fontSize: 9),
      ),
    );
  }
}
