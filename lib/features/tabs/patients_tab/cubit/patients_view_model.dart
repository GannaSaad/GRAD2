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
    final Map<String, NoShowPrediction> currentPredictions = {};
    final Set<String> processedPatients = {};

    for (var appointment in appointments) {
      final patientId = appointment.patientId;
      if (patientId.isEmpty || processedPatients.contains(patientId)) continue;
      processedPatients.add(patientId);

      try {
        // 1. Fetch ALL historical appointments for this patient from Firestore
        final patientHistory = await _appointmentRepo
            .getPatientAppointments(patientId)
            .first
            .timeout(const Duration(seconds: 10), onTimeout: () => []);
        
        int total = patientHistory.length;
        
        // 2. Count any status that contains "cancel" (very flexible)
        int cancelled = patientHistory.where((a) {
          final s = (a.status ?? "").toLowerCase();
          return s.contains("cancel");
        }).length;

        print("DEBUG: Processing $patientId | Total: $total | Cancelled: $cancelled");

        if (total > 0) {
          // 3. Call Google Cloud AI with a longer timeout (15s) to allow for "Cold Start"
          final prediction = await _getNoShowPredictionUseCase
              .execute(patientId, total, cancelled)
              .timeout(const Duration(seconds: 15));
          
          currentPredictions[patientId] = prediction;
        } else {
          currentPredictions[patientId] = NoShowPrediction(probability: 0, patientId: patientId);
        }
      } catch (e) {
        print("AI ERROR for $patientId: $e");
        // If it fails, we keep it as null or 0 to indicate failure
        currentPredictions[patientId] = NoShowPrediction(probability: 0, patientId: patientId);
      }

      if (state is PatientsSuccess && !isClosed) {
        final currentState = state as PatientsSuccess;
        emit(PatientsSuccess(currentState.appointments, predictions: Map.from(currentPredictions)));
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

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
