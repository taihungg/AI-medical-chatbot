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
    final isSeeded = prefs.getBool('isSeeded') ?? false;

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
        patientId: 'PT-001',
        patientName: 'Trần Thế Bảo',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-001',
        doctorName: 'BS. Nguyễn Văn An',
        specialty: 'Khoa Tim mạch',
        dateTime: DateTime.now().add(const Duration(minutes: 30)),
        timeSlot: '08:30 - Hôm nay',
        symptomSummary: 'Đau thắt ngực lan ra cánh tay trái, vã mồ hôi, khó thở mức độ nặng.',
        riskLevel: 'Khẩn cấp',
        aiSummary: 'Bệnh nhân nam 32 tuổi. Tiền sử tăng huyết áp chưa rõ. Đau thắt ngực lan ra tay trái, nghi ngờ nhồi máu cơ tim cấp. Cần ECG và men tim khẩn.',
        isOnline: true,
        status: 'Chờ duyệt',
        vitals: {'pulse': 110.0, 'spO2': 94.0, 'temp': 37.0, 'bpSystolic': 160.0, 'bpDiastolic': 100.0},
      ),
      AppAppointment(
        id: 'APT-002',
        patientId: 'PT-002',
        patientName: 'Lê Thị Thu Thảo',
        branchName: 'Phòng khám Đa khoa Quốc tế',
        doctorId: 'DR-002',
        doctorName: 'BS. Lê Thị Bình',
        specialty: 'Khoa Nội',
        dateTime: DateTime.now().add(const Duration(hours: 1)),
        timeSlot: '09:15 - Hôm nay',
        symptomSummary: 'Viêm họng, ho có đờm, không sốt.',
        riskLevel: 'Thấp',
        aiSummary: 'Bệnh nhân nữ 28 tuổi. Viêm họng cấp, có thể do virus.',
        isOnline: false,
        status: 'Chờ duyệt',
      ),
      AppAppointment(
        id: 'APT-003',
        patientId: 'PT-003',
        patientName: 'Vũ Hoàng Minh',
        branchName: 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: 'DR-003',
        doctorName: 'BS. Trần Quốc Đạt',
        specialty: 'Khoa Thần kinh',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        timeSlot: '14:00 - Hôm qua',
        symptomSummary: 'Đau đầu, chóng mặt kéo dài 3 ngày.',
        riskLevel: 'Trung bình',
        aiSummary: 'Bệnh nhân nam 45 tuổi. Đau đầu có thể do căng thẳng hoặc cao huyết áp. Cần kiểm tra HA.',
        isOnline: true,
        status: 'Đã xác nhận',
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
