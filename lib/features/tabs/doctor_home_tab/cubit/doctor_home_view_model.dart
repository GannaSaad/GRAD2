import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/get_doctor_appointments_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class DoctorHomeState {}
class DoctorHomeInitial extends DoctorHomeState {}
class DoctorHomeLoading extends DoctorHomeState {}
class DoctorHomeSuccess extends DoctorHomeState {
  final List<AppointmentEntity> appointments;
  DoctorHomeSuccess(this.appointments);
}
class DoctorHomeFailure extends DoctorHomeState {
  final String message;
  DoctorHomeFailure(this.message);
}

@injectable
class DoctorHomeViewModel extends Cubit<DoctorHomeState> {
  final GetDoctorAppointmentsUseCase _getDoctorAppointmentsUseCase;

  DoctorHomeViewModel(this._getDoctorAppointmentsUseCase) : super(DoctorHomeInitial());

  void getAppointments() {
    emit(DoctorHomeLoading());
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(DoctorHomeFailure("Doctor not authenticated"));
      return;
    }

    _getDoctorAppointmentsUseCase.call(user.uid).listen(
      (appointments) {
        emit(DoctorHomeSuccess(appointments));
      },
      onError: (error) {
        emit(DoctorHomeFailure(error.toString()));
      },
    );
  }
}
