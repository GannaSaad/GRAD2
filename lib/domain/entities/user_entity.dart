class UserEntity {
  final String uid;
  final String email;
  final String? fullName;
  final String? age;
  final String? role;

  UserEntity({
    required this.uid,
    required this.email,
    this.fullName,
    this.age,
    this.role,
  });
}
