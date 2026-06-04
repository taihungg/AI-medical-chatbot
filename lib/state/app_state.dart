import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../config/env.dart';
import '../services/gemini_service.dart';
import '../services/database_service.dart';
import '../models/models.dart';
import 'chat_directive.dart';
import 'conversation_graph.dart';

enum UserRole { patient, doctor, manager }

class ChatMessage {
  String text;
  final bool isUser;
  final DateTime time;
  final ChatUiDirective? directive;
  bool directiveResolved;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.directive,
    this.directiveResolved = false,
  });
}

class AppState extends ChangeNotifier {
  static AppState? _instance;
  static AppState get instance => _instance ??= AppState._internal();
  AppState._internal() {
    _initDefaults();
    DatabaseService.instance.addListener(() {
      notifyListeners();
    });
  }

  bool _isDoctorBusy = false;
  bool get isDoctorBusy => _isDoctorBusy;

  List<AppAppointment> get appointments => DatabaseService.instance.appointments;

  void toggleDoctorBusy() {
    _isDoctorBusy = !_isDoctorBusy;
    if (!_isDoctorBusy) {
      if (_activeConsultation != null) {
        final currentId = _activeConsultation!.id;
        updateAppointmentStatus(currentId, 'Chưa khám');
        _activeConsultation = null;
        addAuditLog("Bác sĩ tự động chuyển ca $currentId sang CHƯA KHÁM do tắt trạng thái BẬN");
      }
    }
    addAuditLog(_isDoctorBusy ? "Bác sĩ chuyển trạng thái sang ĐANG BẬN" : "Bác sĩ chuyển trạng thái sang ĐANG RẢNH");
    notifyListeners();
  }

  String? get currentlyExaminingId => _activeConsultation?.id;

  bool startExamination(String id) {
    if (_activeConsultation != null && _activeConsultation!.id != id) {
      return false;
    }
    final db = DatabaseService.instance;
    final idx = db.appointments.indexWhere((appt) => appt.id == id);
    if (idx != -1) {
      db.appointments[idx].status = 'Đang khám';
      db.updateAppointment(db.appointments[idx]);
      _activeConsultation = db.appointments[idx];
      _isDoctorBusy = true;
      addAuditLog("Bác sĩ bắt đầu khám ca $id");
      notifyListeners();
      return true;
    }
    return false;
  }

  void stopExamination(String id) {
    if (_activeConsultation?.id == id) {
      updateAppointmentStatus(id, 'Chưa khám');
      _activeConsultation = null;
      notifyListeners();
    }
  }

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

  final List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;

  String _currentRiskLevel = 'Thấp';
  String get currentRiskLevel => _currentRiskLevel;

  String _selectedSymptomsText = '';
  String get selectedSymptomsText => _selectedSymptomsText;

  final ConversationEngine _engine = ConversationEngine();
  final GeminiService? _geminiService = Env.hasGeminiApiKey
      ? GeminiService(apiKey: Env.geminiApiKey, model: Env.geminiModel)
      : null;

  AppAppointment? _activeConsultation;
  AppAppointment? get activeConsultation => _activeConsultation;

  bool _pendingBookingFromAI = false;
  bool get pendingBookingFromAI => _pendingBookingFromAI;

  void triggerBookingFromAI() {
    _pendingBookingFromAI = true;
    addAuditLog("Bệnh nhân đồng ý đặt lịch từ khuyến cáo AI. Chuyển sang tab Đặt lịch khám.");
    notifyListeners();
  }

  void consumeBookingTrigger() {
    _pendingBookingFromAI = false;
    notifyListeners();
  }

  void setActiveConsultation(AppAppointment? appt) {
    _activeConsultation = appt;
    notifyListeners();
  }

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

  void _initDefaults() {
    final opening = _engine.opening();
    _chatMessages.add(ChatMessage(
      text: opening.text,
      isUser: false,
      time: DateTime.now(),
      directive: opening.directive,
    ));
    _auditLogs.add("[Hệ thống] Hệ thống AI Care Bridge đã sẵn sàng phục vụ.");
  }

  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;
    _appendUser(text);
    addAuditLog("Bệnh nhân nhắn: $text");
    _runTurn(ChatTurnContext(userText: text));
  }

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

  void _runTurn(ChatTurnContext ctx) {
    _isAiTyping = true;
    notifyListeners();

    Timer(const Duration(milliseconds: 900), () async {
      ChatMessage? streamingMsg;
      if (_geminiService != null) {
        _isAiTyping = false;
        streamingMsg = ChatMessage(text: '', isUser: false, time: DateTime.now());
        _chatMessages.add(streamingMsg);
        notifyListeners();
      }

      final reply = await _generateBotReply(ctx, onPartialText: (text) {
        if (streamingMsg != null) {
          streamingMsg.text = text;
          notifyListeners();
        }
      });
      _isAiTyping = false;

      if (reply.setSymptomsText != null) {
        _selectedSymptomsText = reply.setSymptomsText!;
      }
      if (reply.setRiskLevel != null) _currentRiskLevel = reply.setRiskLevel!;

      if (streamingMsg != null) {
        _chatMessages.removeLast();
      }
      _chatMessages.add(ChatMessage(
        text: reply.text,
        isUser: false,
        time: DateTime.now(),
        directive: reply.directive,
      ));

      if (reply.triggerBooking) triggerBookingFromAI();

      addAuditLog("AI phản hồi (${reply.directive?.type.name ?? 'text'}).");
      notifyListeners();
    });
  }

  Future<BotReply> _generateBotReply(ChatTurnContext ctx, {void Function(String)? onPartialText}) async {
    final gemini = _geminiService;
    if (gemini == null) {
      return _engine.next(ctx);
    }
    try {
      return await gemini.generateReplyStreamed(
        turn: ctx,
        history: _geminiHistorySnapshot(),
        currentRiskLevel: _currentRiskLevel,
        selectedSymptomsText: _selectedSymptomsText,
        onPartialText: onPartialText,
      );
    } catch (e) {
      addAuditLog("Gemini error: $e");
      final isRateLimit = e.toString().contains('HTTP 429');
      return BotReply(
        text: isRateLimit
            ? 'Hệ thống AI đang nhận quá nhiều yêu cầu. Vui lòng đợi 30 giây rồi thử lại.'
            : 'Đã có lỗi xảy ra khi kết nối tới AI. Vui lòng kiểm tra mạng hoặc thử lại.',
        directive: const ChatUiDirective(
          type: ChatComponentType.retryButton,
          directiveId: 'gemini_retry',
          allowFreeText: false,
        ),
      );
    }
  }

  List<GeminiChatMessage> _geminiHistorySnapshot() {
    return _chatMessages
        .map((m) => GeminiChatMessage(
            role: m.isUser ? 'user' : 'assistant',
            text: m.text,
            directive: m.directive?.toJson(),
            directiveResolved: m.directiveResolved,
          ))
        .toList();
  }

  void resetChat() {
    _chatMessages.clear();
    _currentRiskLevel = 'Thấp';
    _selectedSymptomsText = '';
    _isAiTyping = false;
    _engine.reset();
    
    if (_geminiService != null) {
      addAuditLog("Người dùng đặt lại cuộc trò chuyện AI (Gemini).");
      _runTurn(const ChatTurnContext(userText: '__OPENING__'));
      return;
    }

    final opening = _engine.opening();
    _chatMessages.add(ChatMessage(
      text: opening.text,
      isUser: false,
      time: DateTime.now(),
      directive: opening.directive,
    ));
    addAuditLog("Người dùng đặt lại cuộc trò chuyện AI (Demo).");
    notifyListeners();
  }

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
    final db = DatabaseService.instance;
    
    // Find doctor id
    String doctorId = '';
    try {
      doctorId = db.doctors.firstWhere((d) => d.name == doctor).id;
    } catch (_) {}

    final newAppt = AppAppointment(
      id: id,
      patientId: 'PT-001',
      patientName: patientName,
      branchName: branch,
      doctorId: doctorId,
      doctorName: doctor,
      specialty: specialty,
      dateTime: date,
      timeSlot: slot,
      symptomSummary: symptoms.isEmpty ? "Đăng ký tư vấn y tế tổng quát" : symptoms,
      riskLevel: risk,
      status: "Chưa khám",
      aiSummary: '',
      isOnline: false, // Default to clinic visit unless specified
      vitals: {
        'pulse': (70 + Random().nextInt(25)).toDouble(),
        'spO2': (94 + Random().nextInt(6)).toDouble(),
        'temp': (36.4 + Random().nextInt(15) / 10).toDouble(),
        'systolic': (110 + Random().nextInt(35)).toDouble(),
        'diastolic': (70 + Random().nextInt(20)).toDouble(),
      },
    );

    db.addAppointment(newAppt);
    addAuditLog("Bệnh nhân $patientName đã đặt lịch tại chi nhánh $branch với $doctor");
    notifyListeners();
  }

  void updateConsultationVitals(String apptId, Map<String, double> newVitals) {
    final db = DatabaseService.instance;
    final idx = db.appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1) {
      db.appointments[idx].vitals = newVitals;
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = db.appointments[idx];
      }
      // Note: We don't save to prefs here to avoid excessive writes during simulation
      notifyListeners();
    }
  }

  void updateAppointmentStatus(String apptId, String status) {
    final db = DatabaseService.instance;
    final idx = db.appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1 && db.appointments[idx].status != status) {
      db.appointments[idx].status = status;
      db.updateAppointment(db.appointments[idx]);
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = db.appointments[idx];
      }
      addAuditLog("Ca khám ${db.appointments[idx].id} chuyển sang trạng thái: $status");
      notifyListeners();
    }
  }

  void saveConsultationNotes(String apptId, String notes, List<String> medications) {
    final db = DatabaseService.instance;
    final idx = db.appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1) {
      db.appointments[idx].clinicalNotes = notes;
      db.appointments[idx].prescriptionList = medications;
      db.updateAppointment(db.appointments[idx]);
      
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = db.appointments[idx];
      }
      addAuditLog("Bác sĩ cập nhật ghi chú bệnh án cho ${db.appointments[idx].patientName}");
      notifyListeners();
    }
  }

  void signPrescription(String apptId) {
    final db = DatabaseService.instance;
    final idx = db.appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1) {
      db.appointments[idx].prescriptionSigned = true;
      db.appointments[idx].status = 'Đã khám';
      db.updateAppointment(db.appointments[idx]);
      
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = null;
      }
      addAuditLog("BS đã ký và ban hành đơn thuốc số $apptId của bệnh nhân ${db.appointments[idx].patientName}");
      notifyListeners();
    }
  }

  Timer? _vitalsTimer;
  void startVitalsSimulation() {
    _vitalsTimer?.cancel();
    _vitalsTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      bool updated = false;
      final db = DatabaseService.instance;
      if (_activeConsultation != null) {
        final idx = db.appointments.indexWhere((a) => a.id == _activeConsultation!.id);
        if (idx != -1) {
          final curVitals = Map<String, double>.from(db.appointments[idx].vitals);
          final pulseDiff = -2 + Random().nextInt(5);
          curVitals['pulse'] = max(60, min(140, (curVitals['pulse'] ?? 78) + pulseDiff));

          final sysDiff = -1 + Random().nextInt(3);
          curVitals['systolic'] = max(90, min(180, (curVitals['systolic'] ?? 120) + sysDiff));

          db.appointments[idx].vitals = curVitals;
          _activeConsultation = db.appointments[idx];
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
