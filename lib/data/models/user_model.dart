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
  
  // Patient specific
  final String? allergies;
  final String? medicalInsurance;
  final double? totalToPay;
  final double? totalPaid;

  // Staff specific
  final String? assignedDoctorId;
  final String? assignedDoctorName;

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
    this.allergies,
    this.medicalInsurance,
    this.totalToPay,
    this.totalPaid,
    this.assignedDoctorId,
    this.assignedDoctorName,
  });

  factory UserModel.fromFirebaseUser(
      User user, {
        String? fullName,
        String? age,
        String? role,
        String? phoneNumber,
        String? gender,
        String? speciality,
        String? rank,
        String? experience,
        String? education,
        String? certificates,
        String? allergies,
        String? medicalInsurance,
        String? assignedDoctorId,
        String? assignedDoctorName,
        double? totalToPay,
        double? totalPaid,
      }) {
    return UserModel(
      id: user.uid,
      email: user.email,
      fullName: fullName ?? user.displayName,
      age: age,
      role: role,
      phoneNumber: phoneNumber,
      gender: gender,
      speciality: speciality,
      rank: rank,
      experience: experience,
      education: education,
      certificates: certificates,
      allergies: allergies,
      medicalInsurance: medicalInsurance,
      assignedDoctorId: assignedDoctorId,
      assignedDoctorName: assignedDoctorName,
      totalToPay: totalToPay,
      totalPaid: totalPaid,
    );
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
      allergies: allergies,
      medicalInsurance: medicalInsurance,
      assignedDoctorId: assignedDoctorId,
      assignedDoctorName: assignedDoctorName,
      totalToPay: totalToPay,
      totalPaid: totalPaid,
    );
  }
}
