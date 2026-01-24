import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/use_cases/register_staff_use_case.dart';

abstract class ManagerialStaffState {}
class ManagerialStaffInitial extends ManagerialStaffState {}
class ManagerialStaffLoading extends ManagerialStaffState {}
class ManagerialStaffSuccess extends ManagerialStaffState {
  final String name;
  final String role;
  ManagerialStaffSuccess(this.name, this.role);
}
class ManagerialStaffFailure extends ManagerialStaffState {
  final String message;
  ManagerialStaffFailure(this.message);
}

@injectable
class ManagerialStaffViewModel extends Cubit<ManagerialStaffState> {
  final RegisterStaffUseCase _registerStaffUseCase;

  ManagerialStaffViewModel(this._registerStaffUseCase) : super(ManagerialStaffInitial());

  Future<void> createStaffAccount({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(ManagerialStaffLoading());
    try {
      await _registerStaffUseCase.call(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      emit(ManagerialStaffSuccess(name, role));
    } catch (e) {
      emit(ManagerialStaffFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
