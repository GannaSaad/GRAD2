import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/get_doctor_appointments_use_case.dart';
import '../../../../domain/use_cases/cancel_appointment_use_case.dart';
import '../../../../domain/use_cases/complete_appointment_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class PatientsState {}
class PatientsInitial extends PatientsState {}
class PatientsLoading extends PatientsState {}
class PatientsSuccess extends PatientsState {
  final List<AppointmentEntity> appointments;
  PatientsSuccess(this.appointments);
}
class PatientsFailure extends PatientsState {
  final String message;
  PatientsFailure(this.message);
}

@injectable
class PatientsViewModel extends Cubit<PatientsState> {
  final GetDoctorAppointmentsUseCase _getDoctorAppointmentsUseCase;
  final CancelAppointmentUseCase _cancelAppointmentUseCase;
  final CompleteAppointmentUseCase _completeAppointmentUseCase;
  StreamSubscription? _subscription;

  PatientsViewModel(
    this._getDoctorAppointmentsUseCase,
    this._cancelAppointmentUseCase,
    this._completeAppointmentUseCase,
  ) : super(PatientsInitial());

  void getAppointments() {
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(PatientsFailure("User not authenticated"));
      return;
    }
    getAppointmentsForDoctor(user.uid);
  }

  void getAppointmentsForDoctor(String doctorId) {
    emit(PatientsLoading());
    _subscription?.cancel();
    _subscription = _getDoctorAppointmentsUseCase.call(doctorId).listen(
      (appointments) {
        if (!isClosed) emit(PatientsSuccess(appointments));
      },
      onError: (error) {
        if (!isClosed) emit(PatientsFailure(error.toString()));
      },
    );
  }


  Future<void> cancelAppointment(String id) async {
    try {
      await _cancelAppointmentUseCase.call(id);
    } catch (e) {
      if (!isClosed) emit(PatientsFailure(e.toString()));
    }
  }

  Future<void> markAsComplete(String id) async {
    try {
      await _completeAppointmentUseCase.call(id);
    } catch (e) {
      if (!isClosed) emit(PatientsFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
