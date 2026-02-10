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
  final double? totalToPay;
  final double? totalPaid;

  // Staff specific (Assigned by Doctor)
  final String? assignedDoctorId;
  final String? assignedDoctorName;

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
    this.totalToPay,
    this.totalPaid,
    this.assignedDoctorId,
    this.assignedDoctorName,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? age,
    String? role,
    String? phoneNumber,
    String? gender,
    String? profileImage,
    String? speciality,
    String? rank,
    String? experience,
    String? education,
    String? certificates,
    String? allergies,
    String? medicalInsurance,
    double? totalToPay,
    double? totalPaid,
    String? assignedDoctorId,
    String? assignedDoctorName,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      age: age ?? this.age,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      profileImage: profileImage ?? this.profileImage,
      speciality: speciality ?? this.speciality,
      rank: rank ?? this.rank,
      experience: experience ?? this.experience,
      education: education ?? this.education,
      certificates: certificates ?? this.certificates,
      allergies: allergies ?? this.allergies,
      medicalInsurance: medicalInsurance ?? this.medicalInsurance,
      totalToPay: totalToPay ?? this.totalToPay,
      totalPaid: totalPaid ?? this.totalPaid,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      assignedDoctorName: assignedDoctorName ?? this.assignedDoctorName,
    );
  }
}
