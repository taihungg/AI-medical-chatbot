import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';
import '../splash_screen.dart';
import '../account/account_management_screen.dart';

import 'doctor_components.dart';
import 'doctor_timetable_screen.dart';

class DoctorSpecialistDashboard extends StatefulWidget {
  const DoctorSpecialistDashboard({super.key});

  @override
  State<DoctorSpecialistDashboard> createState() =>
      _DoctorSpecialistDashboardState();
}

class _DoctorSpecialistDashboardState extends State<DoctorSpecialistDashboard> {
  static const String _doctorName = "BS. Nguyễn Văn An";
  String _selectedFilter = 'Tất cả';
  String _searchQuery = '';
  AppAppointment? _selectedAppointment;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;

    return ListenableBuilder(
      listenable: appState,
      builder: (context, child) {
        final double screenWidth = MediaQuery.of(context).size.width;
        final bool isMobile = screenWidth < 700;

        // Filter appointments for today only
        final now = DateTime.now();
        final currentDoctorName = appState.currentUserProfile?.name ?? '';
        
        final todayAppointments = appState.appointments.where((appt) {
          bool isToday = appt.dateTime.year == now.year &&
              appt.dateTime.month == now.month &&
              appt.dateTime.day == now.day;
              
          bool isAssignedToMe = appt.doctorName == currentDoctorName;
          bool isValidStatus = appt.status != 'Chờ duyệt' && appt.status != 'Đã hủy';

          return isToday && isAssignedToMe && isValidStatus;
        }).toList();

        final filteredAppointments = todayAppointments.where((appt) {
          bool statusMatch = true;
          if (_selectedFilter == 'Chờ khám') {
             statusMatch = appt.status == 'Chưa khám' || appt.status == 'Đang khám' || appt.status == 'Đã xác nhận';
          } else if (_selectedFilter == 'Hoàn thành') {
             statusMatch = appt.status == 'Đã khám';
          }
          
          bool nameMatch = _searchQuery.isEmpty ||
              appt.patientName
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
          return statusMatch && nameMatch;
        }).toList();

        // Sort by timeSlot
        filteredAppointments.sort((a, b) => a.timeSlot.compareTo(b.timeSlot));

        // Counts for badges
        final countPending =
            todayAppointments.where((a) => a.status == 'Chưa khám' || a.status == 'Đã xác nhận').length;
        final countExamining =
            todayAppointments.where((a) => a.status == 'Đang khám').length;
        final countDone =
            todayAppointments.where((a) => a.status == 'Đã khám').length;

        final String appBarTitle = (isMobile && _selectedAppointment != null)
            ? "Ca khám: ${_selectedAppointment!.patientName}"
            : (isMobile ? "Bác Sĩ" : "Cổng Thông Tin Bác Sĩ");

        return Scaffold(
          appBar: GlassAppBar(
            title: appBarTitle,
            showLogo: !(isMobile && _selectedAppointment != null),
            automaticallyImplyLeading: false,
            leading: (isMobile && _selectedAppointment != null)
                ? IconButton(
                    icon: const Icon(Icons.arrow_back, color: GlassTheme.oceanBlue),
                    onPressed: () {
                      setState(() {
                        _selectedAppointment = null;
                      });
                    },
                  )
                : null,
          ),
          body: GlassBackground(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // LEFT COLUMN: Queue & Filters
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
                                    Text("CHƯA KHÁM",
                                        style: GlassTheme.labelCaps(
                                            color: GlassTheme.oceanBlue)),
                                    const SizedBox(height: 6),
                                    Text(
                                      "$countPending ca",
                                      style: GlassTheme.h1(
                                              color: GlassTheme.oceanBlue)
                                          .copyWith(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            if (countExamining > 0) ...[
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.all(12),
                                  borderColor:
                                      Colors.orange.withValues(alpha: 0.4),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("ĐANG KHÁM",
                                          style: GlassTheme.labelCaps(
                                              color: Colors.orange)),
                                      const SizedBox(height: 6),
                                      Text(
                                        "$countExamining ca",
                                        style:
                                            GlassTheme.h1(color: Colors.orange)
                                                .copyWith(fontSize: 24),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: GlassCard(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("ĐÃ KHÁM",
                                        style: GlassTheme.labelCaps(
                                            color: Colors.green)),
                                    const SizedBox(height: 6),
                                    Text(
                                      "$countDone ca",
                                      style: GlassTheme.h1(color: Colors.green)
                                          .copyWith(fontSize: 24),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 2. Search bar
                        TextField(
                          onChanged: (val) {
                            setState(() {
                              _searchQuery = val;
                            });
                          },
                          style: GlassTheme.bodyMd(),
                          decoration: InputDecoration(
                            hintText: "Tìm kiếm bệnh nhân...",
                            hintStyle:
                                TextStyle(color: GlassTheme.onSurfaceVariant),
                            prefixIcon: Icon(Icons.search,
                                color: GlassTheme.onSurfaceVariant),
                            filled: true,
                            fillColor: Colors.white.withValues(alpha: 0.4),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. Queue Section Title & Filters
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Hàng Đợi Hôm Nay", style: GlassTheme.h2()),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: GlassTheme.oceanBlue
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${filteredAppointments.length} Ca",
                                style: GlassTheme.labelCaps(
                                        color: GlassTheme.oceanBlue)
                                    .copyWith(fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Choice chip filter layout
                        Row(
                          children: ['Tất cả', 'Chờ khám', 'Hoàn thành']
                              .map((filter) {
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: isSelected
                                        ? GlassTheme.primaryGradient
                                        : null,
                                    color: isSelected
                                        ? null
                                        : Colors.white.withValues(alpha: 0.4),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: isSelected
                                          ? Colors.transparent
                                          : Colors.white38,
                                    ),
                                  ),
                                  child: Text(
                                    filter,
                                    style: GlassTheme.bodyMd(
                                      color: isSelected
                                          ? Colors.white
                                          : GlassTheme.onSurfaceVariant,
                                    ).copyWith(
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 16),

                        // 4. Queue List
                        if (filteredAppointments.isEmpty)
                          const GlassCard(
                            height: 180,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.fact_check_outlined,
                                      size: 40, color: GlassTheme.outline),
                                  SizedBox(height: 10),
                                  Text(
                                    "Hàng đợi rỗng trong bộ lọc này",
                                    style: TextStyle(
                                        color: GlassTheme.onSurfaceVariant),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ...filteredAppointments.map((appt) {
                            final isSelected =
                                _selectedAppointment?.id == appt.id;
                            final isDone = appt.status == 'Đã khám';
                            final isExamining = appt.status == 'Đang khám';
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedAppointment = appt;
                                  });
                                },
                                borderRadius: BorderRadius.circular(20),
                                child: GlassCard(
                                  padding: const EdgeInsets.all(16),
                                  borderColor: isExamining
                                      ? Colors.orange
                                      : isSelected
                                          ? GlassTheme.oceanBlue
                                          : Colors.white,
                                  borderWidth:
                                      isSelected || isExamining ? 1.8 : 1.0,
                                  opacity: isSelected ? 0.8 : 0.6,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                appt.id,
                                                style: GlassTheme.labelCaps(
                                                    color: GlassTheme.outline),
                                              ),
                                              const SizedBox(width: 8),
                                              if (appt.isOnline)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.deepPurple
                                                        .withValues(
                                                            alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: const Text(
                                                    "🌐 Trực tuyến",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color:
                                                            Colors.deepPurple),
                                                  ),
                                                )
                                              else
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 6,
                                                      vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: GlassTheme.oceanBlue
                                                        .withValues(
                                                            alpha: 0.12),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4),
                                                  ),
                                                  child: const Text(
                                                    "🏥 Trực tiếp",
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: GlassTheme
                                                            .oceanBlue),
                                                  ),
                                                ),
                                            ],
                                          ),
                                          StatusBadge(status: appt.status),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(appt.patientName,
                                          style: GlassTheme.h3()),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${appt.specialty} • ${appt.timeSlot}",
                                        style: GlassTheme.bodyMd(
                                            color: GlassTheme.onSurfaceVariant),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "Triệu chứng: ${appt.symptomSummary}",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GlassTheme.bodyMd(
                                                color:
                                                    GlassTheme.onSurfaceVariant)
                                            .copyWith(fontSize: 12),
                                      ),
                                      const SizedBox(height: 10),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                isDone
                                                    ? "✓ Đã duyệt"
                                                    : isExamining
                                                        ? "⏳ Đang khám"
                                                        : "Xem hồ sơ",
                                                style: GlassTheme.labelCaps(
                                                  color: isDone
                                                      ? Colors.green
                                                      : isExamining
                                                          ? Colors.orange
                                                          : GlassTheme
                                                              .oceanBlue,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Icon(
                                                isDone
                                                    ? Icons.check
                                                    : isExamining
                                                        ? Icons.medical_services
                                                        : Icons
                                                            .arrow_forward_ios,
                                                size: 12,
                                                color: isDone
                                                    ? Colors.green
                                                    : isExamining
                                                        ? Colors.orange
                                                        : GlassTheme.oceanBlue,
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

                // RIGHT SIDEBAR / CLINICAL WORKSPACE
                if (_selectedAppointment != null)
                  Expanded(
                    flex: isMobile ? 1 : 18,
                    child: Container(
                      height: double.infinity,
                      decoration: BoxDecoration(
                        border: Border(
                          left: BorderSide(
                            color: isMobile
                                ? Colors.transparent
                                : Colors.white.withValues(alpha: 0.4),
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
                            Icon(Icons.assignment_ind_outlined,
                                size: 48, color: GlassTheme.oceanBlue),
                            SizedBox(height: 16),
                            Text(
                              "Chưa Chọn Ca Khám",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Vui lòng chọn một bệnh nhân từ hàng đợi bên trái để bắt đầu cuộc tư vấn và lập bệnh án lâm sàng.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12,
                                  color: GlassTheme.onSurfaceVariant),
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
  bool _isRecording = false;
  double _recordingSeconds = 0.0;
  Timer? _recordingTimer;
  final List<Offset?> _sigPoints = []; // Digital signature points

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
    final appt =
        appState.appointments.firstWhere((a) => a.id == widget.appointmentId);
    _notesController.text = appt.clinicalNotes;
    _sigPoints.clear();
    _stopRecordingSim();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _recordingTimer?.cancel();
    super.dispose();
  }

  void _stopRecordingSim() {
    _recordingTimer?.cancel();
    setState(() {
      _isRecording = false;
      _recordingSeconds = 0.0;
    });
  }

  // Dictate simulation waves & audio transcript
  void _toggleRecording() {
    if (_isRecording) {
      _recordingTimer?.cancel();
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
        final appt = appState.appointments
            .firstWhere((a) => a.id == widget.appointmentId);
        String text = mockTranscripts[0];
        if (appt.symptomSummary.toLowerCase().contains("ho") ||
            appt.symptomSummary.toLowerCase().contains("phổi")) {
          text = mockTranscripts[1];
        } else if (appt.symptomSummary.toLowerCase().contains("đầu") ||
            appt.symptomSummary.toLowerCase().contains("thần kinh")) {
          text = mockTranscripts[2];
        }

        _notesController.text = "${_notesController.text} $text".trim();
      });
    } else {
      setState(() {
        _isRecording = true;
        _recordingSeconds = 0.0;
      });
      _recordingTimer =
          Timer.periodic(const Duration(milliseconds: 100), (timer) {
        setState(() {
          _recordingSeconds += 0.1;
        });
      });
    }
  }

  void _saveSession() {
    final appState = AppState.instance;
    appState.saveConsultationNotes(
        widget.appointmentId, _notesController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bản nháp bệnh án đã được lưu thành công!"),
        backgroundColor: GlassTheme.oceanBlue,
      ),
    );
  }

  void _finalizeAndSign() {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Vui lòng ghi nhận chẩn đoán/kết luận trước khi ký duyệt."),
          backgroundColor: GlassTheme.error,
        ),
      );
      return;
    }

    if (_sigPoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng vẽ chữ ký tay để ký duyệt bệnh án lâm sàng."),
          backgroundColor: GlassTheme.error,
        ),
      );
      return;
    }

    final appState = AppState.instance;

    // First save
    appState.saveConsultationNotes(
        widget.appointmentId, _notesController.text);
    // Then sign
    appState.signPrescription(widget.appointmentId);

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
              const Icon(Icons.verified, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              Text(
                "Đơn Thuốc Đã Ký Số",
                style: GlassTheme.h2(color: Colors.green),
              ),
              const SizedBox(height: 12),
              const Text(
                "Bệnh án lâm sàng và đơn thuốc đã được ký số mã hóa và truyền tự động về tài khoản Bệnh nhân.",
                style: TextStyle(fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GlassButton(
                text: "Hoàn tất ca khám",
                onPressed: () {
                  Navigator.of(ctx).pop(); // Close dialog
                  widget.onClosed(); // Close panel workspace
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
    final appState = AppState.instance;
    final appt =
        appState.appointments.firstWhere((a) => a.id == widget.appointmentId);

    final bool isMobile = MediaQuery.of(context).size.width < 700;

    Widget bodyContent = Column(
      children: [
        if (!isMobile)
          GlassAppBar(
            title: "Ca khám: ${appt.patientName} (${appt.id})",
            showLogo: false,
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(Icons.close, color: GlassTheme.oceanBlue),
              onPressed: widget.onClosed,
            ),
          ),
        // Core workspace scroll area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 0. Patient & Appointment Info
                Builder(
                  builder: (context) {
                    final patient = DatabaseService.instance.patients.firstWhere(
                      (p) => p.id == appt.patientId,
                      orElse: () => Patient(
                        id: appt.patientId,
                        name: appt.patientName,
                        phone: '',
                        age: 0,
                        gender: 'Không rõ',
                        lastVisit: '',
                        category: '',
                        healthStatus: '',
                        aiSymptomSummary: '',
                      ),
                    );

                    return GlassCard(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Thông Tin Đăng Ký Khám",
                              style: GlassTheme.h3()
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 20, color: GlassTheme.oceanBlue),
                              const SizedBox(width: 8),
                              Text("Bệnh nhân: ${appt.patientName} • ${patient.gender} • ${patient.age > 0 ? '${patient.age} tuổi' : 'N/A'}",
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.description, size: 20, color: GlassTheme.oceanBlue),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Triệu chứng / Ghi chú: ${appt.symptomSummary.isNotEmpty ? appt.symptomSummary : 'Không có'}",
                                ),
                              ),
                            ],
                          ),
                          if (appt.aiSummary.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: GlassTheme.oceanBlue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GlassTheme.oceanBlue.withValues(alpha: 0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.auto_awesome, size: 16, color: GlassTheme.oceanBlue),
                                      const SizedBox(width: 8),
                                      Text("AI Phân Tích (Lúc đặt lịch)", style: GlassTheme.labelCaps(color: GlassTheme.oceanBlue)),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(appt.aiSummary, style: const TextStyle(fontSize: 13, height: 1.4)),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  }
                ),
                const SizedBox(height: 16),
                // 1. Live Consultation & Telehealth Card
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  borderColor: Colors.teal.withValues(alpha: 0.5),
                  opacity: 0.8,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.teal.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.video_call,
                            color: Colors.teal, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Khám Trực Tuyến HD",
                              style: GlassTheme.h3(color: Colors.teal).copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const Text(
                              "Khởi chạy kênh video mã hóa kết nối trực tuyến với bệnh nhân.",
                              style: TextStyle(
                                  fontSize: 11,
                                  color: GlassTheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      GlassButton(
                        text: "Bắt đầu cuộc gọi",
                        width: 120,
                        height: 38,
                        onPressed: () {
                          // Phiên tư vấn được xử lý ngay trong workspace này.
                          appState.setActiveConsultation(appt);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Bắt đầu cuộc gọi tư vấn trực tuyến."),
                              backgroundColor: GlassTheme.oceanBlue,
                            ),
                          );
                        },
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
                          Text("Khám Bệnh & Chẩn Đoán",
                              style: GlassTheme.h3()
                                  .copyWith(fontWeight: FontWeight.bold)),
                          // Voice dictate button
                          _buildDictateButton(),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Recording active wave simulator
                      if (_isRecording) _buildRecordingVisualizer(),

                      GlassTextField(
                        controller: _notesController,
                        label: "",
                        hint:
                            "Nhập kết luận chẩn đoán lâm sàng của bác sĩ tại đây...",
                        maxLines: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),



                // 5. Digital Signature Chữ ký số điện tử
                if (appt.status != 'Hoàn thành')
                  GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: GlassTheme.oceanBlue.withValues(alpha: 0.3),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Chữ Ký Số Của Bác Sĩ",
                                style: GlassTheme.h3()
                                    .copyWith(fontWeight: FontWeight.bold)),
                            TextButton.icon(
                              icon: const Icon(Icons.refresh, size: 14),
                              label: const Text("Xóa ký lại",
                                  style: TextStyle(fontSize: 11)),
                              onPressed: () {
                                setState(() {
                                  _sigPoints.clear();
                                });
                              },
                            ),
                          ],
                        ),
                        const Text(
                          "Ký trực tiếp vào khung dưới để xác thực pháp lý đơn thuốc.",
                          style: TextStyle(
                              fontSize: 11, color: GlassTheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 12),

                        // Signature Pad
                        GestureDetector(
                          onPanUpdate: (details) {
                            RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            Offset localPos =
                                renderBox.globalToLocal(details.globalPosition);
                            // Adjust offset for the specific pad coordinates
                            setState(() {
                              _sigPoints.add(localPos);
                            });
                          },
                          onPanEnd: (details) {
                            setState(() {
                              _sigPoints.add(null); // break line segment
                            });
                          },
                          child: Container(
                            height: 140,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.black12,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white),
                            ),
                            child: CustomPaint(
                              painter: SignaturePainter(points: _sigPoints),
                              child: _sigPoints.isEmpty
                                  ? const Center(
                                      child: Text(
                                        "KÝ TAY TẠI ĐÂY",
                                        style: TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 2.0,
                                            color: Colors.white24,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 24),

                // 6. Action Row buttons
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
                          text: "Ký & Ban Hành",
                          onPressed: _finalizeAndSign,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
      ],
    );

    return bodyContent;
  }



  Widget _buildDictateButton() {
    return InkWell(
      onTap: _toggleRecording,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: _isRecording
              ? GlassTheme.error.withValues(alpha: 0.12)
              : GlassTheme.oceanBlue.withValues(alpha: 0.1),
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

  Widget _buildRecordingVisualizer() {
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

// Custom Painter for Doctor digital drawing signature
class SignaturePainter extends CustomPainter {
  final List<Offset?> points;

  SignaturePainter({required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Colors.white
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (int i = 0; i < points.length - 1; i++) {
      if (points[i] != null && points[i + 1] != null) {
        // Adjust and constrain drawing area
        canvas.drawLine(points[i]!, points[i + 1]!, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SignaturePainter oldDelegate) => true;
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
      final double waveHeight =
          2.0 + 8.0 * sin(seconds * 5 + i) * cos(seconds * 3 + i * 2).abs();
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
