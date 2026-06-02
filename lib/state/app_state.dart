import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

enum UserRole {
  patient,    // Người cần khám bệnh (đánh giá + đặt lịch khám)
  seeker,     // Người cần tư vấn nhanh (đánh giá + tư vấn trực tuyến)
  doctor,     // Bác sĩ (khám, xem vitals, ký đơn thuốc)
  specialist, // Chuyên gia (xem hồ sơ bệnh án chuyên sâu, duyệt yêu cầu)
  manager     // Quản lý phòng khám (xem dashboard thống kê, hiệu suất chi nhánh)
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;

  ChatMessage({required this.text, required this.isUser, required this.time});
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
  final String aiSummary; // Tóm tắt AI từ chat bot, BS đọc trước khi khám
  final bool isOnline; // Xác định ca khám này là online (trực tuyến) hay offline (trực tiếp)
  String status; // 'Chưa khám' | 'Đã khám'
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
    this.aiSummary = '',
    this.isOnline = false,
    this.status = 'Chưa khám',
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
    String? aiSummary,
    bool? isOnline,
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
      aiSummary: aiSummary ?? this.aiSummary,
      isOnline: isOnline ?? this.isOnline,
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

  // Doctor status toggle (Rảnh / Bận)
  bool _isDoctorBusy = false;
  bool get isDoctorBusy => _isDoctorBusy;
  
  void toggleDoctorBusy() {
    _isDoctorBusy = !_isDoctorBusy;
    addAuditLog(_isDoctorBusy ? "Bác sĩ chuyển trạng thái sang ĐANG BẬN" : "Bác sĩ chuyển trạng thái sang ĐANG RẢNH");
    notifyListeners();
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
      case UserRole.patient: return "Người cần khám bệnh";
      case UserRole.seeker: return "Người cần tư vấn nhanh";
      case UserRole.doctor: return "Bác sĩ";
      case UserRole.specialist: return "Chuyên gia y tế";
      case UserRole.manager: return "Quản lý phòng khám";
    }
  }

  // Chatbot State
  final List<ChatMessage> _chatMessages = [];
  List<ChatMessage> get chatMessages => _chatMessages;

  double _assessmentProgress = 0.0;
  double get assessmentProgress => _assessmentProgress;

  bool _isAiTyping = false;
  bool get isAiTyping => _isAiTyping;

  String _currentRiskLevel = 'Thấp'; // Thấp, Trung bình, Cao, Khẩn cấp
  String get currentRiskLevel => _currentRiskLevel;

  String _selectedSymptomsText = '';
  String get selectedSymptomsText => _selectedSymptomsText;

  // Appointments
  final List<AppAppointment> _appointments = [];
  List<AppAppointment> get appointments => _appointments;

  // Selected Appointment for Active Consultations
  AppAppointment? _activeConsultation;
  AppAppointment? get activeConsultation => _activeConsultation;

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
    // Add default chat messages
    _chatMessages.add(ChatMessage(
      text: "Xin chào! Tôi là Trợ lý AI Care Bridge. Tôi có thể giúp bạn đánh giá các triệu chứng sức khỏe ban đầu của mình. Mọi thông tin trò chuyện đều được bảo mật theo tiêu chuẩn HIPAA. Hãy chia sẻ triệu chứng bạn đang gặp phải nhé!",
      isUser: false,
      time: DateTime.now().subtract(const Duration(minutes: 5)),
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
      aiSummary: "BN nam 45 tuổi, đau tức ngực trái lan ra bả vai trái khi gắng sức (leo cầu thang, xách đồ nặng). Kèm khó thở nhẹ. Triệu chứng xuất hiện 3 ngày gần đây, tần suất tăng dần. Không tiền sử bệnh tim mạch. AI đề xuất: Kiểm tra điện tâm đồ (ECG), đánh giá nguy cơ bệnh mạch vành.",
      status: "Chưa khám",
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
      aiSummary: "BN nữ 32 tuổi, ho khan từng cơn kéo dài hơn 3 tuần. Sốt nhẹ 37.3-37.5°C về chiều tối. Sút 2kg trong 2 tuần không rõ nguyên nhân. Tiền sử: phế quản nhạy cảm. AI đề xuất: X-quang phổi thẳng, xét nghiệm công thức máu.",
      status: "Đã khám",
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
      aiSummary: "BN nam 28 tuổi, cơn đau nửa đầu dữ dội kèm buồn nôn và sợ ánh sáng mạnh. Xuất hiện 5 lần trong tháng qua, mỗi lần kéo dài 4-6 tiếng. Tiền sử gia đình có người bị Migraine. AI đề xuất: Khám thần kinh chuyên sâu, cân nhắc MRI não nếu cần.",
      status: "Chưa khám",
      isOnline: true,
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

  // --- ACTIONS ---

  // Chat actions
  void sendChatMessage(String text) {
    if (text.trim().isEmpty) return;

    _chatMessages.add(ChatMessage(
      text: text,
      isUser: true,
      time: DateTime.now(),
    ));
    addAuditLog("Bệnh nhân gửi triệu chứng: $text");
    notifyListeners();

    // Trigger AI response simulation
    _isAiTyping = true;
    _assessmentProgress = min(1.0, _assessmentProgress + 0.25);
    notifyListeners();

    Timer(const Duration(milliseconds: 1500), () {
      _isAiTyping = false;
      String response = "";
      if (_assessmentProgress < 0.3) {
        response = "Tôi đã ghi nhận các triệu chứng này. Để hỗ trợ tốt nhất, xin vui lòng cho biết triệu chứng đã xuất hiện được bao lâu và có kèm theo triệu chứng nào khác không? (ví dụ: sốt, chóng mặt, đau buốt...)";
      } else if (_assessmentProgress < 0.6) {
        _selectedSymptomsText = text;
        response = "Cảm ơn bạn. Mức độ tác động đến sinh hoạt hàng ngày của bạn như thế nào? (Chưa ảnh hưởng nhiều / Khó chịu đáng kể / Rất mệt không thể đi lại)";
      } else if (_assessmentProgress < 0.8) {
        response = "Thông tin rất hữu ích. Tôi đang tiến hành phân tích đối chiếu với kho cơ sở dữ liệu lâm sàng y khoa. Vui lòng nhấn nút 'Xem Kết Quả Phân Tích' để hệ thống hiển thị phân loại và đề xuất y tế tối ưu nhất.";
      } else {
        // Evaluate risk level based on simple keyword search
        final textLower = text.toLowerCase();
        if (textLower.contains('đau ngực') || textLower.contains('khó thở') || textLower.contains('cấp cứu') || textLower.contains('ngất')) {
          _currentRiskLevel = 'Khẩn cấp';
        } else if (textLower.contains('sốt cao') || textLower.contains('đau dữ dội') || textLower.contains('mệt nhiều')) {
          _currentRiskLevel = 'Cao';
        } else if (textLower.contains('ho') || textLower.contains('sổ mũi') || textLower.contains('nhẹ')) {
          _currentRiskLevel = 'Thấp';
        } else {
          _currentRiskLevel = 'Trung bình';
        }
        response = "Quy trình phân tích y khoa AI đã hoàn tất! Vui lòng nhấn nút dưới để xem chi tiết phân loại mức độ nguy cơ triệu chứng và các phương án chăm sóc phù hợp.";
      }

      _chatMessages.add(ChatMessage(
        text: response,
        isUser: false,
        time: DateTime.now(),
      ));
      addAuditLog("AI Phản hồi: ${response.substring(0, min(30, response.length))}...");
      notifyListeners();
    });
  }

  void resetChat() {
    _chatMessages.clear();
    _assessmentProgress = 0.0;
    _currentRiskLevel = 'Thấp';
    _selectedSymptomsText = '';
    _chatMessages.add(ChatMessage(
      text: "Xin chào! Tôi là Trợ lý AI Care Bridge. Hãy chia sẻ bất kỳ triệu chứng sức khỏe nào bạn đang lo lắng nhé!",
      isUser: false,
      time: DateTime.now(),
    ));
    addAuditLog("Người dùng đặt lại luồng đánh giá AI.");
    notifyListeners();
  }

  void completeDirectAssessment(String symptoms, String risk) {
    _selectedSymptomsText = symptoms;
    _currentRiskLevel = risk;
    _assessmentProgress = 1.0;
    addAuditLog("Đánh giá triệu chứng trực tiếp: $symptoms (Mức độ: $risk)");
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
      status: "Chưa khám",
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

  void updateAppointmentStatus(String apptId, String status) {
    final idx = _appointments.indexWhere((appt) => appt.id == apptId);
    if (idx != -1 && _appointments[idx].status != status) {
      _appointments[idx] = _appointments[idx].copyWith(status: status);
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = _appointments[idx];
      }
      addAuditLog("Ca khám ${_appointments[idx].id} chuyển sang trạng thái: $status");
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
        status: 'Đã khám',
      );
      if (_activeConsultation?.id == apptId) {
        _activeConsultation = null;
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
        if (_appointments[i].id == _activeConsultation?.id) {
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
