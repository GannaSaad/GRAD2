import 'dart:async';
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
  StreamSubscription? _subscription; // 1. Create a subscription variable

  DoctorHomeViewModel(this._getDoctorAppointmentsUseCase) : super(DoctorHomeInitial());

  void getAppointments() {
    emit(DoctorHomeLoading());
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(DoctorHomeFailure("Doctor not authenticated"));
      return;
    }

    // 2. Cancel any existing subscription before starting a new one
    _subscription?.cancel();
    
    // 3. Store the new subscription
    _subscription = _getDoctorAppointmentsUseCase.call(user.uid).listen(
      (appointments) {
        if (!isClosed) { // 4. Check if Cubit is still open
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

  @override
  Future<void> close() {
    // 5. Cleanup: Cancel the subscription when the Cubit is closed
    _subscription?.cancel();
    return super.close();
  }
}
