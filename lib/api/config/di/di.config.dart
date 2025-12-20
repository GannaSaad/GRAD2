// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../../data/data_sources/remote/auth_remote_data_source.dart'
    as _i930;
import '../../../data/repos/auth_repo_impl.dart' as _i45;
import '../../../domain/repos/auth_repo.dart' as _i812;
import '../../../domain/use_cases/login_use_case.dart' as _i798;
import '../../../domain/use_cases/register_use_case.dart' as _i311;
import '../../../features/auth/login/cubit/login_view_model.dart' as _i610;
import '../../../features/auth/register/cubit/register_view_model.dart'
    as _i828;
import '../../data_sources/remote/auth_remote_data_source_impl.dart' as _i940;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.factory<_i930.AuthRemoteDataSource>(
      () => _i940.AuthRemoteDataSourceImpl(
        gh<_i59.FirebaseAuth>(),
        gh<_i974.FirebaseFirestore>(),
      ),
    );
    gh.factory<_i812.AuthRepo>(
      () => _i45.AuthRepositoryImpl(gh<_i930.AuthRemoteDataSource>()),
    );
    gh.factory<_i798.LoginUseCase>(
      () => _i798.LoginUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i311.RegisterUseCase>(
      () => _i311.RegisterUseCase(gh<_i812.AuthRepo>()),
    );
    gh.factory<_i828.RegisterViewModel>(
      () => _i828.RegisterViewModel(gh<_i311.RegisterUseCase>()),
    );
    gh.factory<_i610.LoginViewModel>(
      () => _i610.LoginViewModel(gh<_i798.LoginUseCase>()),
    );
    return this;
  }
}
