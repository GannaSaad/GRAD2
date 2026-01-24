import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:dentex_clean/domain/entities/user_entity.dart';
import 'package:dentex_clean/domain/repos/auth_repo.dart';

abstract class AdminHomeState {}
class AdminHomeInitial extends AdminHomeState {}
class AdminHomeLoading extends AdminHomeState {}
class AdminHomeSuccess extends AdminHomeState {
  final List<UserEntity> doctors;
  AdminHomeSuccess(this.doctors);
}
class AdminHomeFailure extends AdminHomeState {
  final String message;
  AdminHomeFailure(this.message);
}

@injectable
class AdminHomeViewModel extends Cubit<AdminHomeState> {
  final AuthRepo _authRepo;

  AdminHomeViewModel(this._authRepo) : super(AdminHomeInitial());

  void getAllDoctors() async {
    emit(AdminHomeLoading());
    try {
      final doctors = await _authRepo.getAllDoctors();
      if (!isClosed) emit(AdminHomeSuccess(doctors));
    } catch (e) {
      if (!isClosed) emit(AdminHomeFailure(e.toString()));
    }
  }

  Future<void> deleteDoctor(String uid) async {
    try {
      await _authRepo.deleteUser(uid);
      // Refresh the list after deletion
      getAllDoctors();
    } catch (e) {
      emit(AdminHomeFailure(e.toString()));
    }
  }
}
