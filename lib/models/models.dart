import 'dart:convert';

// ---------- User Profile ----------
class UserProfile {
  String name;
  String phone;
  String email;
  String address;

  UserProfile({
    required this.name,
    required this.phone,
    required this.email,
    required this.address,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        phone: json['phone'] ?? '',
        email: json['email'] ?? '',
        address: json['address'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'email': email,
        'address': address,
      };

  UserProfile clone() {
    return UserProfile(
      name: name,
      phone: phone,
      email: email,
      address: address,
    );
  }
}


// ---------- Patient ----------
class Patient {
  final String id;
  final String name;
  final String phone;
  final int age;
  final String gender;
  final String lastVisit;
  final String category;
  final String healthStatus;
  final String aiSymptomSummary;

  Patient({
    required this.id,
    required this.name,
    required this.phone,
    required this.age,
    required this.gender,
    required this.lastVisit,
    required this.category,
    required this.healthStatus,
    required this.aiSymptomSummary,
  });

  factory Patient.fromJson(Map<String, dynamic> json) => Patient(
        id: json['id'],
        name: json['name'],
        phone: json['phone'],
        age: json['age'],
        gender: json['gender'],
        lastVisit: json['lastVisit'],
        category: json['category'],
        healthStatus: json['healthStatus'],
        aiSymptomSummary: json['aiSymptomSummary'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'age': age,
        'gender': gender,
        'lastVisit': lastVisit,
        'category': category,
        'healthStatus': healthStatus,
        'aiSymptomSummary': aiSymptomSummary,
      };
}

// ---------- Doctor ----------
class Doctor {
  final String id;
  String name;
  String specialty;
  String branch;
  String status;
  String phone;
  String email;
  int pendingPrescriptions;
  int finalizedPrescriptions;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.branch,
    required this.status,
    required this.phone,
    required this.email,
    required this.pendingPrescriptions,
    required this.finalizedPrescriptions,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) => Doctor(
        id: json['id'],
        name: json['name'],
        specialty: json['specialty'],
        branch: json['branch'],
        status: json['status'],
        phone: json['phone'],
        email: json['email'],
        pendingPrescriptions: json['pendingPrescriptions'],
        finalizedPrescriptions: json['finalizedPrescriptions'],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'specialty': specialty,
        'branch': branch,
        'status': status,
        'phone': phone,
        'email': email,
        'pendingPrescriptions': pendingPrescriptions,
        'finalizedPrescriptions': finalizedPrescriptions,
      };
}

// ---------- Appointment ----------
class AppAppointment {
  final String id;
  final String patientId; // Link to Patient
  final String patientName;
  final String branchName;
  final String doctorId; // Link to Doctor
  final String doctorName;
  final String specialty;
  final DateTime dateTime;
  final String timeSlot;
  final String symptomSummary;
  final String riskLevel;
  final String aiSummary;
  final bool isOnline;
  String status; // 'Chờ duyệt' | 'Đã xác nhận' | 'Đã hủy' | 'Chưa khám' | 'Đã khám'
  String? cancelReason;
  String clinicalNotes;
  bool prescriptionSigned;
  List<String> prescriptionList;
  Map<String, double> vitals; // 'pulse', 'spO2', 'temp', 'bpSystolic', 'bpDiastolic'

  AppAppointment({
    required this.id,
    required this.patientId,
    required this.patientName,
    required this.branchName,
    required this.doctorId,
    required this.doctorName,
    required this.specialty,
    required this.dateTime,
    required this.timeSlot,
    required this.symptomSummary,
    required this.riskLevel,
    required this.aiSummary,
    required this.isOnline,
    required this.status,
    this.cancelReason,
    this.clinicalNotes = '',
    this.prescriptionSigned = false,
    this.prescriptionList = const [],
    this.vitals = const {},
  });

  factory AppAppointment.fromJson(Map<String, dynamic> json) => AppAppointment(
        id: json['id'],
        patientId: json['patientId'] ?? '',
        patientName: json['patientName'],
        branchName: json['branchName'] ?? 'Bệnh viện Đa Khoa Trung Ương',
        doctorId: json['doctorId'] ?? '',
        doctorName: json['doctorName'],
        specialty: json['specialty'],
        dateTime: DateTime.parse(json['dateTime']),
        timeSlot: json['timeSlot'] ?? '',
        symptomSummary: json['symptomSummary'] ?? '',
        riskLevel: json['riskLevel'] ?? 'Thấp',
        aiSummary: json['aiSummary'] ?? '',
        isOnline: json['isOnline'] ?? false,
        status: json['status'],
        cancelReason: json['cancelReason'],
        clinicalNotes: json['clinicalNotes'] ?? '',
        prescriptionSigned: json['prescriptionSigned'] ?? false,
        prescriptionList: List<String>.from(json['prescriptionList'] ?? []),
        vitals: Map<String, double>.from(json['vitals'] ?? {}).map((k, v) => MapEntry(k, v.toDouble())),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'patientId': patientId,
        'patientName': patientName,
        'branchName': branchName,
        'doctorId': doctorId,
        'doctorName': doctorName,
        'specialty': specialty,
        'dateTime': dateTime.toIso8601String(),
        'timeSlot': timeSlot,
        'symptomSummary': symptomSummary,
        'riskLevel': riskLevel,
        'aiSummary': aiSummary,
        'isOnline': isOnline,
        'status': status,
        'cancelReason': cancelReason,
        'clinicalNotes': clinicalNotes,
        'prescriptionSigned': prescriptionSigned,
        'prescriptionList': prescriptionList,
        'vitals': vitals,
      };
}

// ---------- Medication ----------
class Medication {
  final String id;
  final String name;
  final String type;
  final String category;
  final String stock;
  final String usage;
  final String activeIngredient;
  final String sideEffects;
  final String manufacturer;
  final String dateAdded;
  final String price;

  Medication({
    required this.id,
    required this.name,
    required this.type,
    required this.category,
    required this.stock,
    required this.usage,
    required this.activeIngredient,
    required this.sideEffects,
    required this.manufacturer,
    required this.dateAdded,
    required this.price,
  });

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        id: json['id'],
        name: json['name'],
        type: json['type'],
        category: json['category'],
        stock: json['stock'],
        usage: json['usage'],
        activeIngredient: json['activeIngredient'],
        sideEffects: json['sideEffects'],
        manufacturer: json['manufacturer'],
        dateAdded: json['dateAdded'],
        price: json['price'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'category': category,
        'stock': stock,
        'usage': usage,
        'activeIngredient': activeIngredient,
        'sideEffects': sideEffects,
        'manufacturer': manufacturer,
        'dateAdded': dateAdded,
        'price': price,
      };
}
