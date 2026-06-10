import 'dart:async';
import 'package:flutter/material.dart';
import '../../state/app_state.dart';
import '../../widgets/glass_widgets.dart';
import '../../models/models.dart';
import '../../services/gemini_service.dart';
import '../../config/env.dart';
import '../patient/doctor_consultation.dart';

import 'recording_visualizer.dart';

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
  final List<String> _medications = [];
  final TextEditingController _customMedController = TextEditingController();

  bool _isRecording = false;
  bool _isGeneratingSummary = false;
  bool _isGeneratingDiagnosis = false;
  bool _isCheckingDrugs = false;
  String _aiSummary = "";
  
  Timer? _examTimer;
  int _examSeconds = 0;
  
  late AppAppointment _appt;
  late GeminiService _geminiService;

  @override
  void initState() {
    super.initState();
    _geminiService = GeminiService(apiKey: Env.geminiApiKey);
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
    _appt = appState.appointments.firstWhere(
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
    
    _parseSoapNotes(_appt.clinicalNotes);
    _medications.clear();
    _medications.addAll(_appt.prescriptionList);
    _stopRecordingSim();

    // Start timer for offline flow if status is "Đang khám"
    if (!_appt.isOnline && _appt.status == 'Đang khám') {
      if (_examTimer == null || !_examTimer!.isActive) {
        _startExamTimer(reset: false);
      }
    } else {
      _stopExamTimer();
    }
    
    // Auto-generate AI Summary (G1) when opening
    _generateAiSummary();
  }
  
  Future<void> _generateAiSummary() async {
    if (_appt.symptomSummary.isEmpty || _aiSummary.isNotEmpty) return;
    setState(() {
      _isGeneratingSummary = true;
    });
    
    try {
      final prompt = '''
Bạn là trợ lý lâm sàng AI hỗ trợ bác sĩ.
Tóm tắt tình trạng bệnh nhân bằng 2-3 câu tiếng Việt
theo góc nhìn lâm sàng từ mô tả triệu chứng sau:
"${_appt.symptomSummary}"
Kết thúc bằng 1-2 đề xuất thăm khám ban đầu.
Không được đưa ra chẩn đoán xác định.
''';
      final summary = await _geminiService.generateGenericText(prompt);
      if (mounted) {
        setState(() {
          _aiSummary = summary;
          _isGeneratingSummary = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _aiSummary = "Lỗi khi lấy tóm tắt AI: ${e.toString()}";
          _isGeneratingSummary = false;
        });
      }
    }
  }

  Future<void> _suggestDiagnosis() async {
    final sText = _sController.text;
    final oText = _oController.text;
    if (sText.isEmpty && oText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập S và O trước khi gợi ý AI.")),
      );
      return;
    }

    setState(() {
      _isGeneratingDiagnosis = true;
    });

    try {
      final prompt = '''
Dựa trên ghi chú SOAP từ bác sĩ:
S (Chủ quan - bệnh nhân khai): $sText
O (Khách quan - bác sĩ ghi nhận): $oText

Đề xuất ngắn gọn:
A (Chẩn đoán sơ bộ): [1-2 câu]
P (Kế hoạch điều trị): [2-3 bước]

Lưu ý: Đây chỉ là gợi ý AI, bác sĩ toàn quyền quyết định. KHÔNG định dạng bằng Markdown hay in đậm.
''';
      final result = await _geminiService.generateGenericText(prompt);
      
      if (mounted) {
        setState(() {
          // Parse basic A and P from result
          final aIdx = result.indexOf("A (Chẩn đoán sơ bộ):");
          final pIdx = result.indexOf("P (Kế hoạch điều trị):");
          
          if (aIdx != -1 && pIdx != -1) {
             final aText = result.substring(aIdx + 20, pIdx).trim();
             final pText = result.substring(pIdx + 22).trim();
             if (_aController.text.isNotEmpty) _aController.text += "\n";
             _aController.text += aText;
             if (_pController.text.isNotEmpty) _pController.text += "\n";
             _pController.text += pText;
          } else {
             _aController.text += "\nAI Gợi ý:\n$result";
          }
          _isGeneratingDiagnosis = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingDiagnosis = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi AI: ${e.toString()}")),
        );
      }
    }
  }

  Future<void> _checkDrugInteractions() async {
    if (_medications.length < 2) return;
    
    setState(() {
      _isCheckingDrugs = true;
    });

    try {
      final drugList = _medications.join(", ");
      final prompt = '''
Kiểm tra tương tác thuốc giữa các thuốc sau:
$drugList

Liệt kê ngắn gọn bằng tiếng Việt:
- Có tương tác đáng lưu ý không?
- Nếu có, mức độ nào? (Nhẹ/Trung bình/Nghiêm trọng)
- Cần lưu ý gì khi kê cùng?

Nếu không có tương tác đáng kể, trả lời: "Không phát hiện tương tác đáng kể."
KHÔNG sử dụng định dạng markdown.
''';
      final result = await _geminiService.generateGenericText(prompt);
      
      if (mounted) {
        setState(() {
          _isCheckingDrugs = false;
        });
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("🔍 AI Kiểm Tra Tương Tác Thuốc"),
            content: Text(result),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Đóng"),
              )
            ],
          )
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCheckingDrugs = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi AI: ${e.toString()}")),
        );
      }
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
    _customMedController.dispose();
    _examTimer?.cancel();
    super.dispose();
  }

  void _stopRecordingSim() {
    setState(() {
      _isRecording = false;
    });
  }

  void _toggleRecording() {
    if (_isRecording) {
      setState(() {
        _isRecording = false;
        // Mock dictation
        final mockText = "Triệu chứng ho khan từng cơn kéo dài trên 3 tuần, sốt nhẹ dao động 37.5 độ về chiều tối.";
        if (_sController.text.isNotEmpty) {
          _sController.text += "\n$mockText";
        } else {
          _sController.text = mockText;
        }
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
    if (_medications.length >= 2) {
      _checkDrugInteractions();
    }
  }

  void _startOfflineExam() {
    final appState = AppState.instance;
    appState.updateAppointmentStatus(_appt.id, 'Đang khám');
    final idx = appState.appointments.indexWhere((a) => a.id == _appt.id);
    if (idx != -1) {
      setState(() {
        _appt = appState.appointments[idx];
      });
      _startExamTimer();
    }
  }

  void _saveDraft() {
    final combinedNotes = "S: ${_sController.text}\nO: ${_oController.text}\nA: ${_aController.text}\nP: ${_pController.text}";
    final appState = AppState.instance;
    appState.saveConsultationNotes(_appt.id, combinedNotes, _medications);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã lưu nháp"), backgroundColor: Colors.green),
    );
  }

  void _completeExam() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Xác nhận & Gửi đơn"),
        content: const Text("Tôi xác nhận thông tin chẩn đoán và đơn thuốc này chính xác."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Future.delayed(const Duration(milliseconds: 100), () {
                _finalizeExam();
              });
            },
            child: const Text("Gửi đơn cho bệnh nhân"),
          ),
        ],
      )
    );
  }

  void _finalizeExam() {
    _stopExamTimer();
    final combinedNotes = "S: ${_sController.text}\nO: ${_oController.text}\nA: ${_aController.text}\nP: ${_pController.text}";
    final appState = AppState.instance;
    appState.saveConsultationNotes(_appt.id, combinedNotes, _medications);
    appState.updateAppointmentStatus(_appt.id, 'Đã khám');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đã gửi đơn cho bệnh nhân thành công"), backgroundColor: Colors.green),
    );
    widget.onClosed();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = _appt.isOnline ? Colors.purple : Colors.orange;
    
    return Scaffold(
      appBar: GlassAppBar(
        title: _appt.isOnline ? "Tư Vấn Trực Tuyến" : "Khám Trực Tiếp",
        actions: [
          if (!_appt.isOnline && _appt.status == 'Đang khám')
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(
                child: Text(
                  _formatExamTime(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red),
                ),
              ),
            ),
        ],
      ),
      body: GlassBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 16),
                _buildAiSummaryCard(),
                const SizedBox(height: 16),
                
                if (_appt.isOnline && _appt.status != 'Đã khám')
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      text: "Bắt đầu cuộc gọi video",
                      icon: Icons.video_call,
                      onPressed: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => DoctorConsultationScreen(
                              appointment: _appt,
                            ),
                          ),
                        );
                        final appState = AppState.instance;
                        appState.updateAppointmentStatus(_appt.id, 'Đang khám');
                        final idx = appState.appointments.indexWhere((a) => a.id == _appt.id);
                        if (idx != -1) {
                          setState(() {
                            _appt = appState.appointments[idx];
                          });
                        }
                      },
                    ),
                  ),
                  
                if (!_appt.isOnline && _appt.status == 'Chưa khám')
                  SizedBox(
                    width: double.infinity,
                    child: GlassButton(
                      text: "Bắt đầu khám",
                      icon: Icons.play_arrow,
                      onPressed: _startOfflineExam,
                    ),
                  ),

                const SizedBox(height: 16),
                // SOAP + Prescription Card
                GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Wrap(
                            alignment: WrapAlignment.spaceBetween,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text("Bệnh án SOAP", style: GlassTheme.h3()),
                              Wrap(
                                alignment: WrapAlignment.end,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  if (_isRecording) const RecordingVisualizer(),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: _isRecording ? Colors.red : GlassTheme.oceanBlue,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: _toggleRecording,
                                    icon: Icon(_isRecording ? Icons.stop : Icons.mic),
                                    label: Text(_isRecording ? "Dừng ghi" : "Ghi âm AI"),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField("S - Chủ quan", _sController, "Triệu chứng bệnh nhân than phiền..."),
                          const SizedBox(height: 12),
                          _buildTextField("O - Khách quan", _oController, "Ghi nhận lâm sàng, dấu hiệu sinh tồn..."),
                          const SizedBox(height: 12),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("A - Chẩn đoán", style: const TextStyle(fontWeight: FontWeight.bold, color: GlassTheme.oceanBlue)),
                              if (_isGeneratingDiagnosis)
                                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              else
                                TextButton.icon(
                                  onPressed: _suggestDiagnosis,
                                  icon: const Icon(Icons.auto_awesome, color: Colors.purple, size: 18),
                                  label: const Text("AI Gợi Ý Chẩn Đoán", style: TextStyle(color: Colors.purple)),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          GlassTextField(controller: _aController, label: "", hint: "Nhập chẩn đoán sơ bộ...", maxLines: 3),
                          
                          const SizedBox(height: 12),
                          _buildTextField("P - Kế hoạch", _pController, "Kế hoạch điều trị..."),
                          
                          const Divider(height: 32),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text("Đơn thuốc điện tử", style: GlassTheme.h3())),
                              if (_isCheckingDrugs)
                                const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            ],
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              "Amoxicillin 500mg", "Paracetamol 500mg", "Omeprazole 20mg", "Prospan"
                            ].map((med) => ActionChip(
                              label: Text(med),
                              onPressed: () => _addMedication(med),
                            )).toList(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: GlassTextField(
                                  controller: _customMedController,
                                  label: "",
                                  hint: "Nhập tên thuốc khác...",
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: GlassTheme.oceanBlue),
                                onPressed: () => _addMedication(_customMedController.text),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ..._medications.map((m) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(m),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  setState(() => _medications.remove(m));
                                },
                              ),
                            ),
                          )),
                          
                          const SizedBox(height: 32),
                          Row(
                            children: [
                              Expanded(
                                child: GlassButton(
                                  text: "Lưu ghi chú",
                                  isPrimary: false,
                                  onPressed: _saveDraft,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: GlassButton(
                                  text: "Gửi đơn",
                                  onPressed: _appt.status == 'Đã khám' ? () {} : _completeExam,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: GlassTheme.oceanBlue)),
        const SizedBox(height: 8),
        GlassTextField(controller: controller, label: "", hint: hint, maxLines: 3),
      ],
    );
  }

  Widget _buildHeaderCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: GlassTheme.oceanBlue,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_appt.patientName, style: GlassTheme.h3()),
                    const SizedBox(height: 4),
                    Text("ID: ${_appt.patientId} • Nam • 29T", style: const TextStyle(color: GlassTheme.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildAiSummaryCard() {
    return GlassCard(
      borderColor: Colors.teal.shade300,
      borderWidth: 1.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.teal),
              const SizedBox(width: 8),
              Text("AI Tóm Tắt Triệu Chứng", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
            ],
          ),
          const SizedBox(height: 12),
          if (_isGeneratingSummary)
             const Center(child: CircularProgressIndicator())
          else if (_aiSummary.isNotEmpty)
             Text(_aiSummary, style: const TextStyle(height: 1.5))
          else
             Text(_appt.symptomSummary),
          const SizedBox(height: 12),
          if (_appt.riskLevel == 'Cao' || _appt.riskLevel == 'Khẩn cấp')
             Container(
               padding: const EdgeInsets.all(8),
               decoration: BoxDecoration(color: Colors.red.shade100, borderRadius: BorderRadius.circular(8)),
               child: Row(
                 children: [
                   const Icon(Icons.warning, color: Colors.red, size: 16),
                   const SizedBox(width: 8),
                   Text("Nguy cơ: ${_appt.riskLevel}", style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                 ]
               )
             )
        ],
      ),
    );
  }
}
