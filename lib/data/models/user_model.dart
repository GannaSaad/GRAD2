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
  final String? speciality;
  final String? certificates;
  final String? allergies;
  final String? medicalInsurance;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    this.age,
    this.role,
    this.phoneNumber,
    this.gender,
    this.speciality,
    this.certificates,
    this.allergies,
    this.medicalInsurance,
  });

  factory UserModel.fromFirebaseUser(
      User user, {
        String? fullName,
        String? age,
        String? role,
        String? phoneNumber,
        String? gender,
        String? speciality,
        String? certificates,
        String? allergies,
        String? medicalInsurance,
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
      certificates: certificates,
      allergies: allergies,
      medicalInsurance: medicalInsurance,
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
      certificates: certificates,
      allergies: allergies,
      medicalInsurance: medicalInsurance,
    );
  }
}
