import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String? age;
  final String? role;
  final String? phoneNumber;
  final String? gender;
  
  // Doctor specific
  final String? speciality;
  final String? rank;
  final String? experience;
  final String? education;
  final String? certificates;
  final String? clinicName; // Added Clinic Name
  
  // Patient specific
  final String? allergies;
  final String? medicalInsurance;
  final double? totalToPay;
  final double? totalPaid;

  // Staff specific
  final String? assignedDoctorId;
  final String? assignedDoctorName;

  // Supplier specific
  final String? companyId;
  final String? address;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.age,
    this.role,
    this.phoneNumber,
    this.gender,
    this.speciality,
    this.rank,
    this.experience,
    this.education,
    this.certificates,
    this.clinicName,
    this.allergies,
    this.medicalInsurance,
    this.totalToPay,
    this.totalPaid,
    this.assignedDoctorId,
    this.assignedDoctorName,
    this.companyId,
    this.address,
  });

  factory UserModel.fromFirestore(Map<String, dynamic> json, String id) {
    return UserModel(
      id: id,
      email: json['email'],
      fullName: json['fullName'],
      age: json['age'],
      role: json['role'],
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      speciality: json['speciality'],
      rank: json['rank'],
      experience: json['experience'],
      education: json['education'],
      certificates: json['certificates'],
      clinicName: json['clinicName'],
      allergies: json['allergies'],
      medicalInsurance: json['medicalInsurance'],
      assignedDoctorId: json['assignedDoctorId'],
      assignedDoctorName: json['assignedDoctorName'],
      totalToPay: (json['totalToPay'] as num?)?.toDouble(),
      totalPaid: (json['totalPaid'] as num?)?.toDouble(),
      companyId: json['companyId'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'fullName': fullName,
      'age': age,
      'role': role,
      'phoneNumber': phoneNumber,
      'gender': gender,
      'speciality': speciality,
      'rank': rank,
      'experience': experience,
      'education': education,
      'certificates': certificates,
      'clinicName': clinicName,
      'allergies': allergies,
      'medicalInsurance': medicalInsurance,
      'assignedDoctorId': assignedDoctorId,
      'assignedDoctorName': assignedDoctorName,
      'totalToPay': totalToPay,
      'totalPaid': totalPaid,
      'companyId': companyId,
      'address': address,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: id,
      email: email ?? '',
      fullName: fullName ?? '',
      age: age,
      role: role,
      phoneNumber: phoneNumber,
      gender: gender,
      speciality: speciality,
      rank: rank,
      experience: experience,
      education: education,
      certificates: certificates,
      clinicName: clinicName,
      allergies: allergies,
      medicalInsurance: medicalInsurance,
      assignedDoctorId: assignedDoctorId,
      assignedDoctorName: assignedDoctorName,
      totalToPay: totalToPay,
      totalPaid: totalPaid,
      companyId: companyId,
      address: address,
    );
  }
}
