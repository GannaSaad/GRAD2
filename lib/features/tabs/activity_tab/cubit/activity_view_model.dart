import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/get_patient_appointments_use_case.dart';
import '../../../../domain/use_cases/cancel_appointment_use_case.dart';
import '../../../../domain/use_cases/reschedule_appointment_use_case.dart';
import '../../../../domain/use_cases/get_booked_slots_use_case.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class ActivityState {
  final List<AppointmentEntity> appointments;
  ActivityState({this.appointments = const []});
}

class ActivityInitial extends ActivityState {}

class ActivityLoading extends ActivityState {
  ActivityLoading({super.appointments});
}

class ActivitySuccess extends ActivityState {
  final String? actionMessage;
  ActivitySuccess(List<AppointmentEntity> appointments, {this.actionMessage}) 
      : super(appointments: appointments);
}

class ActivityActionLoading extends ActivityState {
  ActivityActionLoading(List<AppointmentEntity> appointments) 
      : super(appointments: appointments);
}

class ActivityFailure extends ActivityState {
  final String message;
  ActivityFailure(this.message, {super.appointments});
}

class ActivityBookedSlotsLoaded extends ActivityState {
  final List<String> availableSlots;
  ActivityBookedSlotsLoaded(List<AppointmentEntity> appointments, this.availableSlots) 
      : super(appointments: appointments);
}

@injectable
class ActivityViewModel extends Cubit<ActivityState> {
  final GetPatientAppointmentsUseCase _getPatientAppointmentsUseCase;
  final CancelAppointmentUseCase _cancelAppointmentUseCase;
  final RescheduleAppointmentUseCase _rescheduleAppointmentUseCase;
  final GetBookedSlotsUseCase _getBookedSlotsUseCase;
  
  StreamSubscription? _appointmentsSubscription;

  ActivityViewModel(
    this._getPatientAppointmentsUseCase,
    this._cancelAppointmentUseCase,
    this._rescheduleAppointmentUseCase,
    this._getBookedSlotsUseCase,
  ) : super(ActivityInitial());

  void getAppointments() {
    if (isClosed) return;

    emit(ActivityLoading(appointments: state.appointments));
    final user = getIt<AuthCubit>().currentUser;
    if (user == null) {
      if (!isClosed) emit(ActivityFailure("User not authenticated", appointments: state.appointments));
      return;
    }

    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = _getPatientAppointmentsUseCase.call(user.uid).listen(
      (appointments) {
        if (!isClosed) {
          emit(ActivitySuccess(appointments));
        }
      },
      onError: (error) {
        if (!isClosed) {
          emit(ActivityFailure(error.toString(), appointments: state.appointments));
        }
      },
    );
  }

  Future<void> fetchAvailableSlots(String doctorId, DateTime date) async {
    try {
      final bookedSlots = await _getBookedSlotsUseCase.call(doctorId, date);
      
      final allSlots = [
        "09:00 AM", "09:30 AM", "10:00 AM", "10:30 AM",
        "11:00 AM", "11:30 AM", "01:00 PM", "01:30 PM",
        "02:00 PM", "02:30 PM", "03:00 PM", "03:30 PM"
      ];

      final availableSlots = allSlots.where((slot) => !bookedSlots.contains(slot)).toList();
      emit(ActivityBookedSlotsLoaded(state.appointments, availableSlots));
    } catch (e) {
      emit(ActivityFailure(e.toString(), appointments: state.appointments));
    }
  }

  Future<void> cancelAppointment(String appointmentId) async {
    if (isClosed) return;

    emit(ActivityActionLoading(state.appointments));
    try {
      await _cancelAppointmentUseCase.call(appointmentId);
      // Success will be emitted by the Stream listener automatically
    } catch (e) {
      if (!isClosed) {
        emit(ActivityFailure(e.toString(), appointments: state.appointments));
      }
    }
  }

  Future<void> rescheduleAppointment(String appointmentId, DateTime newDate, String newTime) async {
    if (isClosed) return;

    emit(ActivityActionLoading(state.appointments));
    try {
      await _rescheduleAppointmentUseCase.call(appointmentId, newDate, newTime);
      // Success will be emitted by the Stream listener automatically
    } catch (e) {
      if (!isClosed) {
        emit(ActivityFailure(e.toString(), appointments: state.appointments));
      }
    }
  }

  @override
  Future<void> close() async {
    await _appointmentsSubscription?.cancel();
    return super.close();
  }
}
