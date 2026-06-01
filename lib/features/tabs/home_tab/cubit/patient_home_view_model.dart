import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/use_cases/get_patient_appointments_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class PatientHomeState {}
class PatientHomeInitial extends PatientHomeState {}
class PatientHomeLoading extends PatientHomeState {}
class PatientHomeSuccess extends PatientHomeState {
  final List<AppointmentEntity> appointments;
  final UserEntity user;
  final String greeting;
  PatientHomeSuccess(this.appointments, this.user, this.greeting);
}
class PatientHomeFailure extends PatientHomeState {
  final String message;
  PatientHomeFailure(this.message);
}

@injectable
class PatientHomeViewModel extends Cubit<PatientHomeState> {
  final GetPatientAppointmentsUseCase _getPatientAppointmentsUseCase;
  StreamSubscription? _appointmentsSubscription;

  PatientHomeViewModel(this._getPatientAppointmentsUseCase) : super(PatientHomeInitial());

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good morning";
    if (hour < 17) return "Good afternoon";
    return "Good evening";
  }

  void init() {
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      emit(PatientHomeFailure("User not authenticated"));
      return;
    }

    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = _getPatientAppointmentsUseCase.call(user.uid).listen(
      (appointments) {
        if (!isClosed) {
          emit(PatientHomeSuccess(appointments, user, getGreeting()));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(PatientHomeFailure(error.toString()));
        }
      },
    );
  }

  @override
  Future<void> close() {
    _appointmentsSubscription?.cancel();
    return super.close();
  }
}
