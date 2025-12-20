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
  }) async {
    final userModel = await _remoteDataSource.register(
      email: email,
      password: password,
      fullName: name,
      age: age,
      role: role,
    );

    return userModel.toEntity();
  }

  @override
  Future<UserEntity> login({required String email, required String password}) async {
    final userModel = await _remoteDataSource.login(email: email, password: password);

    return userModel.toEntity();
  }
}
