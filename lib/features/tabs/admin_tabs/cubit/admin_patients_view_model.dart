import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/repos/auth_repo.dart';

abstract class AdminPatientsState {}
class AdminPatientsInitial extends AdminPatientsState {}
class AdminPatientsLoading extends AdminPatientsState {}
class AdminPatientsSuccess extends AdminPatientsState {
  final List<UserEntity> patients;
  AdminPatientsSuccess(this.patients);
}
class AdminPatientsFailure extends AdminPatientsState {
  final String message;
  AdminPatientsFailure(this.message);
}

@injectable
class AdminPatientsViewModel extends Cubit<AdminPatientsState> {
  final AuthRepo _authRepo;

  AdminPatientsViewModel(this._authRepo) : super(AdminPatientsInitial());

  void getAllPatients() async {
    emit(AdminPatientsLoading());
    try {
      final patients = await _authRepo.getAllPatients();
      emit(AdminPatientsSuccess(patients));
    } catch (e) {
      emit(AdminPatientsFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
