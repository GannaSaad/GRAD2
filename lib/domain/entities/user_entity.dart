class UserEntity {
  final String uid;
  final String email;
  final String? fullName;
  final String? age;
  final String? role;
  final String? phoneNumber;
  final String? gender;
  final String? profileImage;
  
  // Doctor specific
  final String? speciality;
  final String? rank;
  final String? experience;
  final String? education;
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
    this.profileImage,
    this.speciality,
    this.rank,
    this.experience,
    this.education,
    this.certificates,
    this.allergies,
    this.medicalInsurance,
  });
}
