import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/appointment_entity.dart';
import '../../../../domain/use_cases/get_doctor_appointments_use_case.dart';
import '../../../../domain/use_cases/cancel_appointment_use_case.dart';
import '../../../../domain/use_cases/complete_appointment_use_case.dart';
import '../../../../domain/use_cases/get_no_show_prediction_use_case.dart';
import '../../../../domain/entities/no_show_prediction.dart';
import '../../../../domain/repos/appointment_repo.dart';
import '../../../auth/auth_cubit/auth_cubit.dart';
import '../../../../api/config/di/di.dart';

abstract class PatientsState {}
class PatientsInitial extends PatientsState {}
class PatientsLoading extends PatientsState {}
class PatientsSuccess extends PatientsState {
  final List<AppointmentEntity> appointments;
  final Map<String, NoShowPrediction> predictions;
  PatientsSuccess(this.appointments, {this.predictions = const {}});
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
  final GetNoShowPredictionUseCase _getNoShowPredictionUseCase;
  final AppointmentRepo _appointmentRepo;
  StreamSubscription? _subscription;

  PatientsViewModel(
    this._getDoctorAppointmentsUseCase,
    this._cancelAppointmentUseCase,
    this._completeAppointmentUseCase,
    this._getNoShowPredictionUseCase,
    this._appointmentRepo,
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
        if (!isClosed) {
          emit(PatientsSuccess(appointments));
          _loadPredictionsForPatients(appointments);
        }
      },
      onError: (error) {
        if (!isClosed) emit(PatientsFailure(error.toString()));
      },
    );
  }

  void _loadPredictionsForPatients(List<AppointmentEntity> appointments) async {
    final Map<String, NoShowPrediction> newPredictions = {};
    final Set<String> uniquePatientIds = appointments.map((a) => a.patientId).where((id) => id.isNotEmpty).cast<String>().toSet();
    
    final List<Future> predictionFutures = [];

    for (String patientId in uniquePatientIds) {
      final future = _appointmentRepo.getPatientAppointments(patientId).first.then((history) async {
        int total = history.length;
        int cancelled = history.where((a) => a.status == 'Cancelled').length;

        if (total > 0) {
          try {
            final prediction = await _getNoShowPredictionUseCase.execute(patientId, total, cancelled);
            newPredictions[patientId] = prediction;
          } catch (e) {
            print("Prediction failed for $patientId: $e");
          }
        }
      });
      predictionFutures.add(future);
    }

    await Future.wait(predictionFutures);

    if (!isClosed) {
      final currentState = state;
      if (currentState is PatientsSuccess) {
        emit(PatientsSuccess(currentState.appointments, predictions: newPredictions));
      }
    }
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

  Future<void> updateAppointmentStatus(String requestId, String status) async {
    try {
      await _appointmentRepo.updateAppointmentStatus(requestId, status);
    } catch (e) {
      if (!isClosed) emit(PatientsFailure(e.toString()));
    }
  }

  Future<void> resolveEmergency(String requestId, String status, bool isEmergency) async {
    try {
      await _appointmentRepo.resolveEmergency(requestId, status, isEmergency);
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
