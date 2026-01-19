import 'package:injectable/injectable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repos/auth_repo.dart';
import '../data_sources/remote/auth_remote_data_source.dart';

@Injectable(as: AuthRepo)
class AuthRepositoryImpl implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> register({
    required String email,
    required String password,
    required String name,
    required String age,
    required String role,
    required String phoneNumber,
    required String gender,
    String? speciality,
    String? rank,
    String? experience,
    String? education,
    String? certificates,
    String? allergies,
    String? medicalInsurance,
  }) async {
    final userModel = await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: name,
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
    );

    return userModel.toEntity();
  }

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final userModel = await _remoteDataSource.login(email: email, password: password);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> getUserData(String uid) async {
    final userModel = await _remoteDataSource.getUserData(uid);
    return userModel.toEntity();
  }

  @override
  Future<UserEntity> loginWithGoogle() async {
    final userModel = await _remoteDataSource.loginWithGoogle();
    return userModel.toEntity();
  }

  @override
  Future<List<UserEntity>> getAllDoctors() async {
    final models = await _remoteDataSource.getAllDoctors();
    return models.map((model) => model.toEntity()).toList();
  }
}
