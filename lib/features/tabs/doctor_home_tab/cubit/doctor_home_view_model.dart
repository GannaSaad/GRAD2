import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/get_doctor_appointments_use_case.dart';
import '../../../../domain/repos/appointment_repo.dart';
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
  // Use getIt internally to maintain compatibility with existing generated DI code
  final AppointmentRepo _appointmentRepo = getIt<AppointmentRepo>();
  StreamSubscription? _subscription;

  DoctorHomeViewModel(this._getDoctorAppointmentsUseCase) : super(DoctorHomeInitial());

  void getAppointments() {
    emit(DoctorHomeLoading());
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(DoctorHomeFailure("Doctor not authenticated"));
      return;
    }

    _subscription?.cancel();
    _subscription = _getDoctorAppointmentsUseCase.call(user.uid).listen(
      (appointments) {
        if (!isClosed) {
          emit(DoctorHomeSuccess(appointments));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(DoctorHomeFailure(error.toString()));
        }
      },
    );
  }

  Future<void> updateAppointmentStatus(String appointmentId, String status) async {
    try {
      await _appointmentRepo.updateAppointmentStatus(appointmentId, status);
    } catch (e) {
      if (!isClosed) {
        emit(DoctorHomeFailure(e.toString()));
      }
    }
  }

  Future<void> resolveEmergency(String appointmentId, String status, bool isEmergency) async {
    try {
      await _appointmentRepo.resolveEmergency(appointmentId, status, isEmergency);
    } catch (e) {
      if (!isClosed) {
        emit(DoctorHomeFailure(e.toString()));
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
