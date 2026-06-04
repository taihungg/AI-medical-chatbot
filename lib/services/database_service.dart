import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class DatabaseService extends ChangeNotifier {
  static final DatabaseService instance = DatabaseService._();
  DatabaseService._();

  List<Patient> patients = [];
  List<Doctor> doctors = [];
  List<AppAppointment> appointments = [];
  List<Medication> medications = [];

  bool _isLoaded = false;
  bool get isLoaded => _isLoaded;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if we already seeded the db
    final isSeeded = false; // Force re-seed during development

    if (!isSeeded) {
      await _seedInitialData(prefs);
    } else {
      await _loadFromPrefs(prefs);
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _loadFromPrefs(SharedPreferences prefs) async {
    final patientsStr = prefs.getString('patients');
    final doctorsStr = prefs.getString('doctors');
    final appointmentsStr = prefs.getString('appointments');
    final medicationsStr = prefs.getString('medications');

    if (patientsStr != null) {
      final List dec = jsonDecode(patientsStr);
      patients = dec.map((e) => Patient.fromJson(e)).toList();
    }
    if (doctorsStr != null) {
      final List dec = jsonDecode(doctorsStr);
      doctors = dec.map((e) => Doctor.fromJson(e)).toList();
    }
    if (appointmentsStr != null) {
      final List dec = jsonDecode(appointmentsStr);
      appointments = dec.map((e) => AppAppointment.fromJson(e)).toList();
    }
    if (medicationsStr != null) {
      final List dec = jsonDecode(medicationsStr);
      medications = dec.map((e) => Medication.fromJson(e)).toList();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('patients', jsonEncode(patients.map((e) => e.toJson()).toList()));
    await prefs.setString('doctors', jsonEncode(doctors.map((e) => e.toJson()).toList()));
    await prefs.setString('appointments', jsonEncode(appointments.map((e) => e.toJson()).toList()));
    await prefs.setString('medications', jsonEncode(medications.map((e) => e.toJson()).toList()));
    notifyListeners();
  }

  Future<void> _seedInitialData(SharedPreferences prefs) async {
    patients = [
      Patient(
        id: 'PT-001',
        name: 'Trần Thế Bảo',
        phone: '0901234567',
        age: 32,
        gender: 'Nam',
        lastVisit: '2024-05-10',
        category: 'Thường xuyên',
        healthStatus: 'Khẩn cấp',
        aiSymptomSummary: 'Đau thắt ngực lan ra cánh tay trái, vã mồ hôi, khó thở mức độ nặng.',
      ),
      Patient(
        id: 'PT-002',
        name: 'Lê Thị Thu Thảo',
        phone: '0912345678',
        age: 28,
        gender: 'Nữ',
        lastVisit: '2024-04-15',
        category: 'Thường xuyên',
        healthStatus: 'Ổn định',
        aiSymptomSummary: 'Viêm họng, ho có đờm, không sốt.',
      ),
      Patient(
        id: 'PT-003',
        name: 'Vũ Hoàng Minh',
        phone: '0987654321',
        age: 45,
        gender: 'Nam',
        lastVisit: '2024-05-20',
        category: 'Mới',
        healthStatus: 'Ổn định',
        aiSymptomSummary: 'Đau đầu, chóng mặt kéo dài 3 ngày.',
      ),
      Patient(
        id: 'PT-004',
        name: 'Nguyễn Ngọc Anh',
        phone: '0909090909',
        age: 60,
        gender: 'Nữ',
        lastVisit: '2024-03-01',
        category: 'VIP',
        healthStatus: 'Ổn định',
        aiSymptomSummary: 'Khám định kỳ tiểu đường.',
      )
    ];

    doctors = [
      Doctor(id: 'DR-001', name: 'BS. Nguyễn Văn An', specialty: 'Khoa Tim mạch', branch: 'Bệnh viện Đa Khoa Trung Ương', status: 'Hoạt động', phone: '0901112223', email: 'an.nguyen@hospital.com', pendingPrescriptions: 3, finalizedPrescriptions: 12),
      Doctor(id: 'DR-002', name: 'BS. Lê Thị Bình', specialty: 'Khoa Nội', branch: 'Phòng khám Đa khoa Quốc tế', status: 'Hoạt động', phone: '0901112224', email: 'binh.le@hospital.com', pendingPrescriptions: 1, finalizedPrescriptions: 8),
      Doctor(id: 'DR-003', name: 'BS. Trần Quốc Đạt', specialty: 'Khoa Thần kinh', branch: 'Bệnh viện Đa Khoa Trung Ương', status: 'Nghỉ phép', phone: '0901112225', email: 'dat.tran@hospital.com', pendingPrescriptions: 0, finalizedPrescriptions: 25),
      Doctor(id: 'DR-004', name: 'BS. Phạm Minh Tâm', specialty: 'Khoa Tim mạch', branch: 'Phòng khám Đa khoa Quốc tế', status: 'Hoạt động', phone: '0901112226', email: 'tam.pham@hospital.com', pendingPrescriptions: 5, finalizedPrescriptions: 40),
    ];

    appointments = [
      AppAppointment(
        id: 'APT-001',
        patientId: 'PT-004',
        patientName: 'Nguyễn Ngọc Anh',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-001',
        doctorName: 'BS. Nguyễn Văn An',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
        timeSlot: '11:30 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Nguyễn Ngọc Anh',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Nguyễn Ngọc Anh',
        isOnline: false,
        status: 'Đang khám',
      ),
      AppAppointment(
        id: 'APT-002',
        patientId: 'PT-008',
        patientName: 'Võ Tấn Phát',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: '',
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        timeSlot: '16:00 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Võ Tấn Phát',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Võ Tấn Phát',
        isOnline: false,
        status: 'Chờ duyệt',
      ),
      AppAppointment(
        id: 'APT-003',
        patientId: 'PT-007',
        patientName: 'Đặng Thị Huyền',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-002',
        doctorName: 'BS. Lê Thị Bình',
        specialty: 'Khoa Nội',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 2)),
        timeSlot: '08:00 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Đặng Thị Huyền',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Đặng Thị Huyền',
        isOnline: true,
        status: 'Đã hủy',
      ),
      AppAppointment(
        id: 'APT-004',
        patientId: 'PT-001',
        patientName: 'Trần Thế Bảo',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-004',
        doctorName: 'BS. Phạm Minh Tâm',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 3)),
        timeSlot: '15:30 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Trần Thế Bảo',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Trần Thế Bảo',
        isOnline: true,
        status: 'Đã xác nhận',
      ),
      AppAppointment(
        id: 'APT-005',
        patientId: 'PT-001',
        patientName: 'Trần Thế Bảo',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-002',
        doctorName: 'BS. Lê Thị Bình',
        specialty: 'Khoa Nội',
        dateTime: DateTime.now().add(const Duration(hours: 4)),
        timeSlot: '11:00 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Trần Thế Bảo',
        riskLevel: 'Thấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Trần Thế Bảo',
        isOnline: false,
        status: 'Đã xác nhận',
      ),
      AppAppointment(
        id: 'APT-006',
        patientId: 'PT-010',
        patientName: 'Đỗ Thị Kim Thanh',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-003',
        doctorName: 'BS. Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        dateTime: DateTime.now().add(const Duration(hours: -2)),
        timeSlot: '10:30 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Đỗ Thị Kim Thanh',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Đỗ Thị Kim Thanh',
        isOnline: false,
        status: 'Chưa khám',
      ),
      AppAppointment(
        id: 'APT-007',
        patientId: 'PT-002',
        patientName: 'Lê Thị Thu Thảo',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-001',
        doctorName: 'BS. Nguyễn Văn An',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        timeSlot: '15:00 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Lê Thị Thu Thảo',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Lê Thị Thu Thảo',
        isOnline: false,
        status: 'Đang khám',
      ),
      AppAppointment(
        id: 'APT-008',
        patientId: 'PT-002',
        patientName: 'Lê Thị Thu Thảo',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-001',
        doctorName: 'BS. Nguyễn Văn An',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().add(const Duration(hours: 4)),
        timeSlot: '08:00 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Lê Thị Thu Thảo',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Lê Thị Thu Thảo',
        isOnline: false,
        status: 'Đã xác nhận',
      ),
      AppAppointment(
        id: 'APT-009',
        patientId: 'PT-005',
        patientName: 'Lâm Quốc Việt',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-003',
        doctorName: 'BS. Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        dateTime: DateTime.now().add(const Duration(hours: 0)),
        timeSlot: '07:30 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Lâm Quốc Việt',
        riskLevel: 'Thấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Lâm Quốc Việt',
        isOnline: false,
        status: 'Đã khám',
      ),
      AppAppointment(
        id: 'APT-010',
        patientId: 'PT-001',
        patientName: 'Trần Thế Bảo',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-004',
        doctorName: 'BS. Phạm Minh Tâm',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().add(const Duration(hours: -4)),
        timeSlot: '08:30 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Trần Thế Bảo',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Trần Thế Bảo',
        isOnline: false,
        status: 'Đã khám',
      ),
      AppAppointment(
        id: 'APT-011',
        patientId: 'PT-002',
        patientName: 'Lê Thị Thu Thảo',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-003',
        doctorName: 'BS. Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 3)),
        timeSlot: '15:00 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Lê Thị Thu Thảo',
        riskLevel: 'Thấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Lê Thị Thu Thảo',
        isOnline: true,
        status: 'Đã khám',
      ),
      AppAppointment(
        id: 'APT-012',
        patientId: 'PT-001',
        patientName: 'Trần Thế Bảo',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-002',
        doctorName: 'BS. Lê Thị Bình',
        specialty: 'Khoa Nội',
        dateTime: DateTime.now().add(const Duration(hours: 0)),
        timeSlot: '11:30 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Trần Thế Bảo',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Trần Thế Bảo',
        isOnline: true,
        status: 'Chưa khám',
      ),
      AppAppointment(
        id: 'APT-013',
        patientId: 'PT-005',
        patientName: 'Lâm Quốc Việt',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-004',
        doctorName: 'BS. Phạm Minh Tâm',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 2)),
        timeSlot: '08:00 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Lâm Quốc Việt',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Lâm Quốc Việt',
        isOnline: true,
        status: 'Đã khám',
      ),
      AppAppointment(
        id: 'APT-014',
        patientId: 'PT-004',
        patientName: 'Nguyễn Ngọc Anh',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-003',
        doctorName: 'BS. Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 3)),
        timeSlot: '11:30 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Nguyễn Ngọc Anh',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Nguyễn Ngọc Anh',
        isOnline: false,
        status: 'Chưa khám',
      ),
      AppAppointment(
        id: 'APT-015',
        patientId: 'PT-006',
        patientName: 'Trương Mỹ Lan',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: '',
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        timeSlot: '16:00 - Ngày mai',
        symptomSummary: 'Triệu chứng bệnh nhân Trương Mỹ Lan',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Trương Mỹ Lan',
        isOnline: false,
        status: 'Chờ duyệt',
      ),
      AppAppointment(
        id: 'APT-016',
        patientId: 'PT-004',
        patientName: 'Nguyễn Ngọc Anh',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: '',
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now().subtract(const Duration(days: 1)).add(const Duration(hours: 1)),
        timeSlot: '12:00 - Hôm qua',
        symptomSummary: 'Triệu chứng bệnh nhân Nguyễn Ngọc Anh',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Nguyễn Ngọc Anh',
        isOnline: true,
        status: 'Chờ duyệt',
      ),
      AppAppointment(
        id: 'APT-017',
        patientId: 'PT-008',
        patientName: 'Võ Tấn Phát',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-002',
        doctorName: 'BS. Lê Thị Bình',
        specialty: 'Khoa Nội',
        dateTime: DateTime.now().add(const Duration(days: 1, hours: 5)),
        timeSlot: '11:00 - Ngày mai',
        symptomSummary: 'Triệu chứng bệnh nhân Võ Tấn Phát',
        riskLevel: 'Thấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Võ Tấn Phát',
        isOnline: false,
        status: 'Chưa khám',
      ),
      AppAppointment(
        id: 'APT-018',
        patientId: 'PT-008',
        patientName: 'Võ Tấn Phát',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: '',
        doctorName: '',
        specialty: '',
        dateTime: DateTime.now().add(const Duration(hours: 0)),
        timeSlot: '10:30 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Võ Tấn Phát',
        riskLevel: 'Trung bình',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Võ Tấn Phát',
        isOnline: true,
        status: 'Chờ duyệt',
      ),
      AppAppointment(
        id: 'APT-019',
        patientId: 'PT-001',
        patientName: 'Trần Thế Bảo',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-003',
        doctorName: 'BS. Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        dateTime: DateTime.now().add(const Duration(hours: 2)),
        timeSlot: '08:30 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Trần Thế Bảo',
        riskLevel: 'Thấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Trần Thế Bảo',
        isOnline: true,
        status: 'Đang khám',
      ),
      AppAppointment(
        id: 'APT-020',
        patientId: 'PT-008',
        patientName: 'Võ Tấn Phát',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-002',
        doctorName: 'BS. Lê Thị Bình',
        specialty: 'Khoa Nội',
        dateTime: DateTime.now().add(const Duration(hours: 0)),
        timeSlot: '12:00 - Hôm nay',
        symptomSummary: 'Triệu chứng bệnh nhân Võ Tấn Phát',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Tóm tắt AI cho bệnh nhân Võ Tấn Phát',
        isOnline: false,
        status: 'Đã hủy',
      ),
    ];


    medications = [
      Medication(id: 'MED-001', name: 'Paracetamol 500mg', type: 'Viên nén', category: 'Thuốc giảm đau, hạ sốt', stock: 'Còn hàng', usage: 'Uống 1 viên mỗi 4-6 giờ', activeIngredient: 'Paracetamol', sideEffects: 'Dị ứng, mẩn ngứa, buồn nôn', manufacturer: 'Dược Hậu Giang', dateAdded: '12/01/2024', price: '25,000 đ/vỉ'),
      Medication(id: 'MED-002', name: 'Ibuprofen 400mg', type: 'Viên nang', category: 'Thuốc kháng viêm (NSAIDs)', stock: 'Còn hàng', usage: 'Uống 1 viên sau ăn', activeIngredient: 'Ibuprofen', sideEffects: 'Đau dạ dày, buồn nôn', manufacturer: 'Traphaco', dateAdded: '20/02/2024', price: '35,000 đ/vỉ'),
      Medication(id: 'MED-003', name: 'Amoxicillin 500mg', type: 'Viên nang', category: 'Kháng sinh', stock: 'Sắp hết', usage: 'Uống 1 viên x 2 lần/ngày', activeIngredient: 'Amoxicillin', sideEffects: 'Tiêu chảy, dị ứng', manufacturer: 'Domesco', dateAdded: '05/03/2024', price: '45,000 đ/vỉ'),
      Medication(id: 'MED-004', name: 'Vitamin C 1000mg', type: 'Viên sủi', category: 'Vitamin & Khoáng chất', stock: 'Còn hàng', usage: 'Uống 1 viên/ngày, sáng', activeIngredient: 'Vitamin C', sideEffects: 'Sỏi thận (nếu dùng kéo dài)', manufacturer: 'Bayer', dateAdded: '15/04/2024', price: '75,000 đ/tuýp'),
    ];

    await prefs.setBool('isSeeded', true);
    await _saveToPrefs();
  }

  // --- Actions ---

  Future<void> addAppointment(AppAppointment apt) async {
    appointments.insert(0, apt);
    await _saveToPrefs();
  }

  Future<void> updateAppointment(AppAppointment apt) async {
    final index = appointments.indexWhere((e) => e.id == apt.id);
    if (index != -1) {
      appointments[index] = apt;
      await _saveToPrefs();
    }
  }

  Future<void> addDoctor(Doctor doc) async {
    doctors.insert(0, doc);
    await _saveToPrefs();
  }

  Future<void> updateDoctor(Doctor doc) async {
    final index = doctors.indexWhere((e) => e.id == doc.id);
    if (index != -1) {
      doctors[index] = doc;
      await _saveToPrefs();
    }
  }
}
