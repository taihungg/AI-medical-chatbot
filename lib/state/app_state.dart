import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import 'chat_directive.dart';
import 'conversation_graph.dart';

enum UserRole {
  patient,    // Bệnh nhân (đánh giá triệu chứng + đặt lịch khám)
  doctor,     // Bác sĩ (khám, xem vitals, ký đơn thuốc)
  manager     // Quản lý phòng khám (xem dashboard thống kê)
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  /// Optional interactive component the bot wants rendered under this bubble.
  /// Null for user messages and plain-text bot messages.
  final ChatUiDirective? directive;

  /// True once the user has answered this message's directive. The UI then
  /// renders the component read-only so only the latest directive stays live.
  bool directiveResolved;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.directive,
    this.directiveResolved = false,
  });
}

class AppAppointment {
  final String id;
  final String patientName;
  final String branchName;
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String timeSlot;
  final String symptomSummary;
  final String riskLevel; // 'Thấp' | 'Trung bình' | 'Cao' | 'Khẩn cấp'
  String status; // 'Chờ khám' | 'Đang khám' | 'Hoàn thành'
  String clinicalNotes;
  bool prescriptionSigned;
  List<String> prescriptionList;
  Map<String, double> vitals; // 'pulse', 'spO2', 'temp', 'bpSystolic', 'bpDiastolic'

  AppAppointment({
    required this.id,
    required this.patientName,
    required this.branchName,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.timeSlot,
    required this.symptomSummary,
    required this.riskLevel,
    this.status = 'Chờ khám',
    this.clinicalNotes = '',
    this.prescriptionSigned = false,
    this.prescriptionList = const [],
    this.vitals = const {
      'pulse': 78,
      'spO2': 98,
      'temp': 36.8,
      'systolic': 120,
      'diastolic': 80,
    },
  });

  AppAppointment copyWith({
    String? status,
    String? clinicalNotes,
    bool? prescriptionSigned,
    List<String>? prescriptionList,
    Map<String, double>? vitals,
  }) {
    return AppAppointment(
      id: id,
      patientName: patientName,
      branchName: branchName,
      doctorName: doctorName,
      specialty: specialty,
      dateTime: dateTime,
      timeSlot: timeSlot,
      symptomSummary: symptomSummary,
      riskLevel: riskLevel,
      status: status ?? this.status,
      clinicalNotes: clinicalNotes ?? this.clinicalNotes,
      prescriptionSigned: prescriptionSigned ?? this.prescriptionSigned,
      prescriptionList: prescriptionList ?? this.prescriptionList,
      vitals: vitals ?? this.vitals,
    );
  }
}

class AppState extends ChangeNotifier {
  // Singleton Pattern
  static final AppState _instance = AppState._internal();
  static AppState get instance => _instance;
  AppState._internal() {
    _initDefaults();
  }

  // Active User Role
  UserRole _currentRole = UserRole.patient;
  UserRole get currentRole => _currentRole;

  void setRole(UserRole role) {
    _currentRole = role;
    addAuditLog("Đã chuyển đổi vai trò sang: ${_getRoleNameVi(role)}");
    notifyListeners();
  }

  String _getRoleNameVi(UserRole role) {
    switch (role) {
      case UserRole.patient: return "Bệnh nhân";
      case UserRole.doctor: return "Bác sĩ";
      case UserRole.manager: return "Quản lý phòng khám";
    }
  }

  // Chatbot State
  final List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;

  String _currentRiskLevel = 'Thấp'; // Thấp, Trung bình, Cao, Khẩn cấp
  String get currentRiskLevel => _currentRiskLevel;

  String _selectedSymptomsText = '';
  String get selectedSymptomsText => _selectedSymptomsText;

  /// The scripted bot brain. This is the MVP seam — swapping in Gemini means
  /// replacing what [_generateBotReply] delegates to, not touching the UI.
  final ConversationEngine _engine = ConversationEngine();

  /// Set true for one notify cycle when the bot decides to route the patient
  /// to the SOS emergency screen. The chat UI consumes it and navigates.
  bool _pendingEmergencySos = false;
  bool get pendingEmergencySos => _pendingEmergencySos;
  void consumeEmergencySos() => _pendingEmergencySos = false;

  // Appointments
  final List<AppAppointment> _appointments = [];
  List<AppAppointment> get appointments => _appointments;

  // Selected Appointment for Active Consultations
  AppAppointment? _activeConsultation;
  AppAppointment? get activeConsultation => _activeConsultation;

  // Booking Tab Trigger from AI Chatbot
  // When AI recommends booking and patient agrees, this flag is set
  // to auto-switch to the "Đặt lịch khám" tab with pre-filled data.
  bool _pendingBookingFromAI = false;
  bool get pendingBookingFromAI => _pendingBookingFromAI;

  /// Called when the patient agrees to book (e.g. taps the report card CTA).
  /// Sets the trigger flag so MainFramework auto-switches to the booking tab.
  /// [symptoms] and [risk] are already stored in selectedSymptomsText / currentRiskLevel
  /// before this call, so the booking tab can read them directly.
  void triggerBookingFromAI() {
    _pendingBookingFromAI = true;
    addAuditLog("Bệnh nhân đồng ý đặt lịch từ khuyến cáo AI. Chuyển sang tab Đặt lịch khám.");
    notifyListeners();
  }

  /// Called by MainFramework after it has switched to the booking tab.
  /// Resets the flag so it doesn't trigger again on subsequent rebuilds.
  void consumeBookingTrigger() {
    _pendingBookingFromAI = false;
    notifyListeners();
  }

  void setActiveConsultation(AppAppointment? appt) {
    _activeConsultation = appt;
    notifyListeners();
  }

  // Clinic Management Operations
  final List<String> _auditLogs = [];
  List<String> get auditLogs => _auditLogs;

  void addAuditLog(String message) {
    final now = DateTime.now();
    final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}";
    _auditLogs.insert(0, "[$timeStr] $message");
    if (_auditLogs.length > 50) {
      _auditLogs.removeLast();
    }
    notifyListeners();
  }

  // Pre-populated default records
  void _initDefaults() {
    // Seed the opening bot turn (greeting + first interactive directive).
    final opening = _engine.opening();
    _chatMessages.add(ChatMessage(
      text: opening.text,
      isUser: false,
      time: DateTime.now(),
      directive: opening.directive,
    ));

    // Prepopulate 3 default appointments for Doctor/Specialist and Manager view
    _appointments.add(AppAppointment(
      id: "APT-8801",
      patientName: "Trần Thế Bảo",
      branchName: "Phòng khám A - Quận 1, TP. HCM",
      doctorName: "BS. Nguyễn Văn An",
      specialty: "Khoa Tim mạch",
      dateTime: DateTime.now(),
      timeSlot: "08:30 - 09:00",
      symptomSummary: "Đau tức ngực trái lan ra vai, kèm khó thở khi leo cầu thang",
      riskLevel: "Cao",
      status: "Chờ khám",
      vitals: {
        'pulse': 88,
        'spO2': 95,
        'temp': 37.0,
        'systolic': 142,
        'diastolic': 92,
      },
    ));

    _appointments.add(AppAppointment(
      id: "APT-8802",
      patientName: "Lê Thị Thu Thảo",
      branchName: "Phòng khám B - Hoàn Kiếm, Hà Nội",
      doctorName: "BS. Lê Thị Bình",
      specialty: "Khoa Nội tổng quát",
      dateTime: DateTime.now(),
      timeSlot: "10:15 - 10:45",
      symptomSummary: "Ho khan kéo dài 3 tuần, sốt nhẹ về chiều và sút cân không rõ nguyên nhân",
      riskLevel: "Trung bình",
      status: "Hoàn thành",
      clinicalNotes: "Bệnh nhân có tiền sử phế quản nhạy cảm. Đã kê đơn kháng sinh nhẹ và siro ho thảo dược.",
      prescriptionSigned: true,
      prescriptionList: ["Amoxicillin 500mg (20 viên) - Uống ngày 2 lần", "Siro Ho Prospan (1 chai) - Uống ngày 3 lần"],
      vitals: {
        'pulse': 76,
        'spO2': 98,
        'temp': 37.3,
        'systolic': 115,
        'diastolic': 75,
      },
    ));

    _appointments.add(AppAppointment(
      id: "APT-8803",
      patientName: "Vũ Hoàng Minh",
      branchName: "Phòng khám C - Hải Châu, Đà Nẵng",
      doctorName: "BS. Trần Quốc Đạt",
      specialty: "Khoa Thần kinh",
      dateTime: DateTime.now().add(const Duration(days: 1)),
      timeSlot: "14:00 - 14:30",
      symptomSummary: "Đau nửa đầu dữ dội kèm buồn nôn, sợ ánh sáng mạnh",
      riskLevel: "Cao",
      status: "Chờ khám",
      vitals: {
        'pulse': 92,
        'spO2': 99,
        'temp': 36.6,
        'systolic': 130,
        'diastolic': 85,
      },
    ));

    _auditLogs.add("[Hệ thống] Hệ thống AI Care Bridge đã sẵn sàng phục vụ.");
    _auditLogs.add("[Hệ thống] Nạp dữ liệu thành công cho 4 chi nhánh phòng khám.");
  }

  // --- CHAT ACTIONS ---
  // The chat is a thin shell over a single seam, [_generateBotReply]. Both
  // free-text messages and interactive-component responses funnel through
  // [_runTurn], so swapping the scripted brain for Gemini touches one method.

  /// Patient typed a free-text message.
  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    _appendUser(text);
    addAuditLog("Bệnh nhân nhắn: $text");
    _runTurn(ChatTurnContext(userText: text));
  }

  /// Patient answered an interactive component (chip / slider / etc).
  /// [userEcho] is the human-readable bubble to show for their choice.
  void respondToDirective({
    required String directiveId,
    String? selectedValue,
    List<String>? selectedValues,
    double? sliderValue,
    required String userEcho,
  }) {
    _markDirectiveResolved(directiveId);
    _appendUser(userEcho);
    addAuditLog("Bệnh nhân chọn: $userEcho");
    _runTurn(ChatTurnContext(
      directiveId: directiveId,
      selectedValue: selectedValue,
      selectedValues: selectedValues,
      sliderValue: sliderValue,
    ));
  }

  void _appendUser(String text) {
    _chatMessages.add(ChatMessage(text: text, isUser: true, time: DateTime.now()));
    notifyListeners();
  }

  void _markDirectiveResolved(String directiveId) {
    for (final m in _chatMessages) {
      if (m.directive?.directiveId == directiveId) {
        m.directiveResolved = true;
      }
    }
  }

  /// Runs one bot turn: typing indicator → seam → apply reply + side effects.
  void _runTurn(ChatTurnContext ctx) {
    _isAiTyping = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 900), () async {
      final reply = await _generateBotReply(ctx);
      _isAiTyping = false;

      if (reply.setSymptomsText != null) _selectedSymptomsText = reply.setSymptomsText!;
      if (reply.setRiskLevel != null) _currentRiskLevel = reply.setRiskLevel!;

      _chatMessages.add(ChatMessage(
        text: reply.text,
        isUser: false,
        time: DateTime.now(),
        directive: reply.directive,
      ));

      if (reply.triggerEmergencySos) _pendingEmergencySos = true;
      if (reply.triggerBooking) triggerBookingFromAI();

      addAuditLog("AI phản hồi (${reply.directive?.type.name ?? 'text'}).");
      notifyListeners();
    });
  }

  /// THE SEAM. MVP: scripted engine. Later: `return GeminiService.reply(ctx)`.
  Future<BotReply> _generateBotReply(ChatTurnContext ctx) async {
    return _engine.next(ctx);
  }

  void resetChat() {
    _chatMessages.clear();
    _currentRiskLevel = 'Thấp';
    _selectedSymptomsText = '';
    _isAiTyping = false;
    final opening = _engine.opening();
    _chatMessages.add(ChatMessage(
      text: opening.text,
      isUser: false,
      time: DateTime.now(),
      directive: opening.directive,
    ));
    addAuditLog("Người dùng đặt lại cuộc trò chuyện AI.");
    notifyListeners();
  }

  // Appointment Booking
  void bookAppointment({
    required String patientName,
    required String branch,
    required String doctor,
    required String specialty,
    required DateTime date,
    required String slot,
    required String symptoms,
    required String risk,
  }) {
    final id = "APT-${(1000 + Random().nextInt(8999))}";
    final newAppt = AppAppointment(
      id: id,
      patientName: patientName,
      branchName: branch,
      doctorName: doctor,
      specialty: specialty,
      dateTime: date,
      timeSlot: slot,
      symptomSummary: symptoms.isEmpty ? "Đăng ký tư vấn y tế tổng quát" : symptoms,
      riskLevel: risk,
      status: "Chờ khám",
      vitals: {
        'pulse': (70 + Random().nextInt(25)).toDouble(),
        'spO2': (94 + Random().nextInt(6)).toDouble(),
        'temp': (36.4 + Random().nextInt(15) / 10).toDouble(),
        'systolic': (110 + Random().nextInt(35)).toDouble(),
        'diastolic': (70 + Random().nextInt(20)).toDouble(),
      },
    );

    _appointments.insert(0, newAppt);
    addAuditLog("Bệnh nhân $patientName đã đặt lịch tại chi nhánh $branch với $doctor");
    notifyListeners();
  }

  // Doctor Clinical Actions
  void updateConsultationVitals(String apptId, Map<String, double> newVitals) {
    final idx = _appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1) {
      _appointments[idx] = _appointments[idx].copyWith(vitals: newVitals);
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = _appointments[idx];
      }
      notifyListeners();
    }
  }

  void saveConsultationNotes(String apptId, String notes, List<String> medications) {
    final idx = _appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1) {
      _appointments[idx] = _appointments[idx].copyWith(
        clinicalNotes: notes,
        prescriptionList: medications,
      );
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = _appointments[idx];
      }
      addAuditLog("Bác sĩ cập nhật ghi chú bệnh án cho ${appointments[idx].patientName}");
      notifyListeners();
    }
  }

  void signPrescription(String apptId) {
    final idx = _appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1) {
      _appointments[idx] = _appointments[idx].copyWith(
        prescriptionSigned: true,
        status: 'Hoàn thành',
      );
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = _appointments[idx];
      }
      addAuditLog("BS đã ký và ban hành đơn thuốc số $apptId của bệnh nhân ${appointments[idx].patientName}");
      notifyListeners();
    }
  }

  // Simulation Vitals dynamic pulse effect for Doctor dashboard (animated over time)
  Timer? _vitalsTimer;
  void startVitalsSimulation() {
    _vitalsTimer?.cancel();
    _vitalsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      bool updated = false;
      for (int i = 0; i < _appointments.length; i++) {
        if (_appointments[i].status == 'Đang khám' || _appointments[i].id == _activeConsultation?.id) {
          final curVitals = Map<String, double>.from(_appointments[i].vitals);
          // Subtly fluctuate pulse (-2 to +2)
          final pulseDiff = -2 + Random().nextInt(5);
          curVitals['pulse'] = max(60, min(140, (curVitals['pulse'] ?? 78) + pulseDiff));
          
          // Subtly fluctuate systolic
          final sysDiff = -1 + Random().nextInt(3);
          curVitals['systolic'] = max(90, min(180, (curVitals['systolic'] ?? 120) + sysDiff));

          _appointments[i] = _appointments[i].copyWith(vitals: curVitals);
          if (_activeConsultation?.id == _appointments[i].id) {
            _activeConsultation = _appointments[i];
          }
          updated = true;
        }
      }
      if (updated) {
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _vitalsTimer?.cancel();
    super.dispose();
  }
}
