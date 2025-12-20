class UserEntity {
  final String uid;
  final String email;
  final String? fullName;
  final String? age;
  final String? role;
  final String? phoneNumber;
  final String? gender;
  
  // Doctor specific
  final String? speciality;
  final String? certificates;
  
  // Patient specific
  final String? allergies;
  final String? medicalInsurance;

  UserEntity({
    required this.uid,
    required this.email,
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
}
