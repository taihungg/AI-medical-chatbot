import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';
import '../../services/database_service.dart';
import '../patient/doctor_consultation.dart';

import 'recording_visualizer.dart';
import 'doctor_components.dart';

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
  final TextEditingController _sController = TextEditingController();
  final TextEditingController _oController = TextEditingController();
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _pController = TextEditingController();
  bool _isRecording = false;

  // Timer đếm giờ khám
  Timer? _examTimer;
  int _examSeconds = 0;

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
        patientId: '',
        patientName: 'Lỗi Dữ Liệu',
        doctorId: '',
        doctorName: '',
        branchName: '',
        specialty: '',
        dateTime: DateTime.now(),
        timeSlot: '',
        symptomSummary: '',
        riskLevel: 'Thấp',
        isOnline: false,
        status: '',
        aiSummary: '',
      ),
    );
    _parseSoapNotes(appt.clinicalNotes);
    _stopRecordingSim();

    // Start/stop exam timer based on status
    if (appt.status == 'Đang khám') {
      if (_examTimer == null || !_examTimer!.isActive) {
        _startExamTimer(reset: false);
      }
    } else {
      _stopExamTimer();
    }
  }

  void _parseSoapNotes(String notes) {
    if (notes.contains("S:") && notes.contains("O:")) {
      _sController.text = _extractSoapField(notes, "S:");
      _oController.text = _extractSoapField(notes, "O:");
      _aController.text = _extractSoapField(notes, "A:");
      _pController.text = _extractSoapField(notes, "P:");
    } else {
      _sController.text = notes;
      _oController.clear();
      _aController.clear();
      _pController.clear();
    }
  }

  String _extractSoapField(String text, String prefix) {
    if (!text.contains(prefix)) return "";
    int start = text.indexOf(prefix) + prefix.length;
    int end = text.length;
    for (String p in ["S:", "O:", "A:", "P:"]) {
      if (p == prefix) continue;
      int pIdx = text.indexOf(p, start);
      if (pIdx != -1 && pIdx < end) end = pIdx;
    }
    return text.substring(start, end).trim();
  }

  void _startExamTimer({bool reset = true}) {
    _examTimer?.cancel();
    if (reset) _examSeconds = 0;
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _examSeconds++;
        });
      }
    });
  }

  void _stopExamTimer() {
    _examTimer?.cancel();
    _examSeconds = 0;
  }

  String _formatExamTime() {
    final min = (_examSeconds ~/ 60).toString().padLeft(2, '0');
    final sec = (_examSeconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  @override
  void dispose() {
    _sController.dispose();
    _oController.dispose();
    _aController.dispose();
    _pController.dispose();
    _examTimer?.cancel();
    super.dispose();
  }

  void _stopRecordingSim() {
    setState(() {
      _isRecording = false;
    });
  }

  // --- Mock SOAP-structured AI Dictation ---
  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        final appState = AppState.instance;
        final appt = appState.appointments.firstWhere(
          (a) => a.id == widget.appointmentId,
          orElse: () => AppAppointment(
            id: '',
            patientId: '',
            patientName: '',
            doctorId: '',
            doctorName: '',
            branchName: '',
            specialty: '',
            dateTime: DateTime.now(),
            timeSlot: '',
            symptomSummary: '',
            riskLevel: 'Thấp',
            isOnline: false,
            status: '',
            aiSummary: '',
          ),
        );

        // Structured SOAP mock based on symptoms
        Map<String, String> mock;
        final sym = appt.symptomSummary.toLowerCase();
        if (sym.contains("ho") || sym.contains("phổi") || sym.contains("sốt")) {
          mock = {
            "s":
                "Triệu chứng ho khan từng cơn kéo dài trên 3 tuần, sốt nhẹ dao động 37.5 độ về chiều tối.",
            "o":
                "Lồng ngực gõ trong, ran phế quản nhẹ phổi trái. SpO2: 97%, nhiệt độ: 37.4°C.",
            "a":
                "Viêm phế quản cấp, cần loại trừ viêm phổi. Xét nghiệm thêm X-quang phổi.",
            "p":
                "Kê kháng sinh nhẹ Amoxicillin 500mg, siro ho Prospan. Tái khám sau 5 ngày."
          };
        } else if (sym.contains("đầu") ||
            sym.contains("thần kinh") ||
            sym.contains("chóng mặt")) {
          mock = {
            "s":
                "Cơn đau nửa đầu kiểu Migraine dữ dội kèm buồn nôn, sợ ánh sáng mạnh.",
            "o":
                "Tri giác tỉnh, pupil đều 2 bên, không dấu thần kinh khu trú. HA: 130/85.",
            "a":
                "Migraine không aura, tần suất tăng (5 lần/tháng). Cần MRI loại trừ bệnh lý.",
            "p":
                "Nghỉ ngơi phòng tối, bổ sung Magie, Sumatriptan 50mg khi đau đỉnh điểm."
          };
        } else if (sym.contains("bụng") ||
            sym.contains("dạ dày") ||
            sym.contains("ợ")) {
          mock = {
            "s":
                "Đau thượng vị tái phát sau ăn, kèm ợ nóng, buồn nôn, không nôn ra máu.",
            "o":
                "Ấn đau thượng vị, không phản ứng thành bụng, không gan lách to.",
            "a": "Viêm dạ dày tái phát, nghi H.pylori dương tính.",
            "p":
                "Nội soi dạ dày, test H.pylori. Omeprazole 20mg x 4 tuần, Gaviscon khi có triệu chứng."
          };
        } else {
          mock = {
            "s":
                "Bệnh nhân đau tức vùng xương ức trái, lan tỏa nhẹ ra bả vai trái khi gắng sức.",
            "o":
                "Huyết áp tâm thu 140 mmHg, nhịp tim hơi nhanh (88 bpm), SpO2 95%.",
            "a":
                "Nghi ngờ bệnh mạch vành cấp, cần loại trừ hội chứng vành cấp.",
            "p":
                "Điện tâm đồ (ECG) khẩn trương, lập phác đồ kiểm soát mạch ổn định."
          };
        }

        // Append (not overwrite) to each SOAP field
        if (_sController.text.isNotEmpty) {
          _sController.text = "${_sController.text}\n${mock['s']}";
        } else {
          _sController.text = mock['s']!;
        }
        _oController.text = _oController.text.isEmpty
            ? mock['o']!
            : "${_oController.text}\n${mock['o']}";
        _aController.text = _aController.text.isEmpty
            ? mock['a']!
            : "${_aController.text}\n${mock['a']}";
        _pController.text = _pController.text.isEmpty
            ? mock['p']!
            : "${_pController.text}\n${mock['p']}";

        _checkForAllergies(mock['p']! + mock['a']!);
      });
    } else {
      setState(() {
        _isRecording = true;
      });
    }
  }

  void _checkForAllergies(String text) {
    String lower = text.toLowerCase();
    if (lower.contains("amoxicillin") ||
        lower.contains("penicillin") ||
        lower.contains("aspirin")) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "⚠️ CẢNH BÁO AI: Bệnh nhân có tiền sử dị ứng Penicillin. Kiểm tra đơn thuốc!"),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }



  String _buildCombinedNotes() {
    return "S: ${_sController.text}\nO: ${_oController.text}\nA: ${_aController.text}\nP: ${_pController.text}";
  }

  void _saveSession() {
    final appState = AppState.instance;
    appState.saveConsultationNotes(
        widget.appointmentId, _buildCombinedNotes());
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Bản nháp bệnh án đã được lưu thành công!"),
        backgroundColor: GlassTheme.oceanBlue,
      ),
    );
  }

  void _showPublishConfirmation(BuildContext context) {
    if (_aController.text.trim().isEmpty && _sController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Vui lòng ghi nhận chẩn đoán/kết luận trước khi ban hành."),
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
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: GlassCard(
            borderColor: Colors.green,
            borderWidth: 1.5,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_outline,
                    color: Colors.green, size: 64),
                const SizedBox(height: 16),
                Text("Xác Nhận Ban Hành",
                    style: GlassTheme.h2(color: Colors.green)),
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
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GlassButton(
                        text: "Đồng ý",
                        onPressed: () {
                          final appState = AppState.instance;
                          appState.saveConsultationNotes(widget.appointmentId,
                              _buildCombinedNotes());
                          appState.signPrescription(widget.appointmentId);
                          Navigator.of(ctx).pop();
                          widget.onClosed();
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
      ),
    );
  }

  // --- Hẹn Tái Khám ---
  void _showRebookDialog(BuildContext context, AppAppointment appt) {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 7));
    String selectedSlot = "09:00 - 09:30";
    final slots = [
      "08:00 - 08:30",
      "08:30 - 09:00",
      "09:00 - 09:30",
      "09:30 - 10:00",
      "10:00 - 10:30",
      "10:30 - 11:00",
      "11:00 - 11:30",
      "13:30 - 14:00",
      "14:00 - 14:30",
      "14:30 - 15:00"
    ];
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📅 Hẹn Tái Khám",
                      style: GlassTheme.h3()
                          .copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(appt.patientName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: GlassTheme.oceanBlue)),
                  const SizedBox(height: 16),
                  // Date picker
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setDialogState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white38),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today,
                              size: 18, color: GlassTheme.oceanBlue),
                          const SizedBox(width: 8),
                          Text(
                            "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}",
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          const Spacer(),
                          const Icon(Icons.edit,
                              size: 14, color: GlassTheme.onSurfaceVariant),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text("Chọn khung giờ:",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: slots
                        .map((slot) => ChoiceChip(
                              label: Text(slot,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: selectedSlot == slot
                                          ? Colors.white
                                          : null)),
                              selected: selectedSlot == slot,
                              selectedColor: GlassTheme.oceanBlue,
                              backgroundColor: Colors.white60,
                              onSelected: (val) {
                                if (val) {
                                  setDialogState(() {
                                    selectedSlot = slot;
                                  });
                                }
                              },
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                          child: GlassButton(
                              text: "Hủy",
                              isPrimary: false,
                              onPressed: () => Navigator.of(ctx).pop())),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GlassButton(
                          text: "Xác nhận",
                          onPressed: () {
                            AppState.instance.bookAppointment(
                              patientName: appt.patientName,
                              branch: appt.branchName,
                              doctor: appt.doctorName,
                              specialty: appt.specialty,
                              date: selectedDate,
                              slot: selectedSlot,
                              symptoms:
                                  "Tái khám theo chỉ định từ ca ${appt.id}",
                              risk: 'Thấp',
                            );
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    "✅ Đã đặt lịch tái khám cho ${appt.patientName}"),
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
        ),
      ),
    );
  }

  void _handleStartExam(AppAppointment appt) {
    final appState = AppState.instance;
    final currentStatus = appt.status;

    if (currentStatus == 'Đang khám') {
      // Bấm lần 2 (trực tiếp) → revert về Chưa khám
      appState.stopExamination(appt.id);
      _stopExamTimer();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Đã tạm dừng ca khám."),
            backgroundColor: Colors.orange),
      );
    } else {
      // Bắt đầu khám
      final success = appState.startExamination(appt.id);
      if (success) {
        _startExamTimer(reset: true);
        if (appt.isOnline) {
          // Ca trực tuyến → mở màn hình gọi video tư vấn.
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => DoctorConsultationScreen(appointment: appt),
            ),
          ).then((_) => _loadAppointmentData());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Bắt đầu quy trình khám trực tiếp."),
              backgroundColor: GlassTheme.oceanBlue,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                "⚠️ Đang có ca khám khác (${appState.currentlyExaminingId}). Vui lòng hoàn tất trước."),
            backgroundColor: GlassTheme.error,
          ),
        );
      }
    }
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
        content.isEmpty ? "—" : content,
        style: const TextStyle(fontSize: 13, height: 1.5),
      ),
    );
  }

  Widget _buildInlineStatus(String text, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(text,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  String _generateMockAiSummary(String symptom) {
    if (symptom.isEmpty) {
      return "Bệnh nhân chưa khai báo triệu chứng chi tiết qua AI.";
    }
    final sym = symptom.toLowerCase();
    if (sym.contains("ho") || sym.contains("phổi") || sym.contains("sốt")) {
      return "🤖 Trợ lý AI phân tích: Dấu hiệu nhiễm trùng hô hấp. Triệu chứng: $symptom.\n💡 Đề xuất: Đo SpO2, nghe phổi, cân nhắc X-quang ngực.";
    } else if (sym.contains("đầu") ||
        sym.contains("thần kinh") ||
        sym.contains("chóng mặt")) {
      return "🤖 Trợ lý AI phân tích: Dấu hiệu liên quan hệ thần kinh/tiền đình. Triệu chứng: $symptom.\n💡 Đề xuất: Kiểm tra huyết áp, test Romberg, loại trừ thiếu máu não.";
    } else if (sym.contains("bụng") ||
        sym.contains("dạ dày") ||
        sym.contains("ợ")) {
      return "🤖 Trợ lý AI phân tích: Triệu chứng tiêu hóa nổi bật. Triệu chứng: $symptom.\n💡 Đề xuất: Khám thực thể vùng bụng, khai thác tiền sử H.Pylori.";
    } else {
      return "🤖 Trợ lý AI tổng hợp: Bệnh nhân than phiền về '$symptom'.\n💡 Mức độ rủi ro: Cần bác sĩ đánh giá lâm sàng trực tiếp.";
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppState.instance;
    final appt =
        appState.appointments.firstWhere((a) => a.id == widget.appointmentId);
    final isCompleted = appt.status == 'Đã khám';
    final isExamining = appt.status == 'Đang khám';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: GlassAppBar(
        title: "WORKSPACE LÂM SÀNG: ${appt.patientName} (${appt.id})",
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: GlassTheme.oceanBlue),
          onPressed: widget.onClosed,
        ),
      ),
      body: Column(
        children: [
          // Core workspace scroll area
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // 1. AI Summary Card
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
                        child: const Icon(Icons.psychology,
                            color: GlassTheme.oceanBlue, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tóm Tắt Trợ Lý AI",
                              style: GlassTheme.h3(color: GlassTheme.oceanBlue)
                                  .copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                            ),
                            const SizedBox(height: 8),
                            _buildReadOnlyBox(
                              appt.aiSummary.isEmpty
                                  ? _generateMockAiSummary(appt.symptomSummary)
                                  : appt.aiSummary,
                            ),
                            const SizedBox(height: 12),
                            if (isCompleted)
                              _buildInlineStatus(
                                  "Ca đã hoàn tất, chỉ xem hồ sơ",
                                  Colors.green,
                                  Icons.lock_outline)
                            else
                              GlassButton(
                                text: isExamining
                                    ? (appt.isOnline
                                        ? "⏳ Đang gọi..."
                                        : "⏸ Tạm dừng khám")
                                    : (appt.isOnline
                                        ? "📹 Bắt Đầu Call Video"
                                        : "🏥 Bắt Đầu Khám"),
                                width: 200,
                                height: 38,
                                onPressed: () => _handleStartExam(appt),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. SOAP Notes
                GlassCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Ghi Chú Lâm Sàng (SOAP)",
                              style: GlassTheme.h3().copyWith(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          if (!isCompleted) _buildDictateButton(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_isRecording) const RecordingVisualizer(),
                      if (isCompleted) ...[
                        // Read-only SOAP
                        _buildSoapReadOnly("S — Chủ quan", _sController.text),
                        const SizedBox(height: 8),
                        _buildSoapReadOnly("O — Khách quan", _oController.text),
                        const SizedBox(height: 8),
                        _buildSoapReadOnly("A — Chẩn đoán", _aController.text),
                        const SizedBox(height: 8),
                        _buildSoapReadOnly("P — Kế hoạch", _pController.text),
                      ] else ...[
                        // Editable SOAP
                        GlassTextField(
                            controller: _sController,
                            label: "Subjective (Chủ quan)",
                            hint: "Triệu chứng bệnh nhân than phiền...",
                            maxLines: 2),
                        const SizedBox(height: 8),
                        GlassTextField(
                            controller: _oController,
                            label: "Objective (Khách quan)",
                            hint: "Kết quả thăm khám, sinh hiệu, xét nghiệm...",
                            maxLines: 2),
                        const SizedBox(height: 8),
                        GlassTextField(
                            controller: _aController,
                            label: "Assessment (Đánh giá/Chẩn đoán)",
                            hint: "Chẩn đoán bệnh lý...",
                            maxLines: 2),
                        const SizedBox(height: 8),
                        GlassTextField(
                            controller: _pController,
                            label: "Plan (Kế hoạch điều trị)",
                            hint: "Hướng xử trí, dặn dò bệnh nhân...",
                            maxLines: 2),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 4. Action Row buttons
                if (isCompleted)
                  // Đã khám → chỉ hiện nút Hẹn Tái Khám
                  GlassButton(
                    text: "📅 Hẹn Tái Khám",
                    onPressed: () => _showRebookDialog(context, appt),
                  )
                else
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

  Widget _buildSoapReadOnly(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: GlassTheme.oceanBlue)),
        const SizedBox(height: 4),
        _buildReadOnlyBox(content),
      ],
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
          color: _isRecording
              ? GlassTheme.error.withValues(alpha: 0.12)
              : GlassTheme.oceanBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: _isRecording ? GlassTheme.error : Colors.transparent),
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
