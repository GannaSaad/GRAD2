import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/repos/auth_repo.dart';
import '../../../../domain/repos/appointment_repo.dart';
import '../../../../domain/use_cases/get_no_show_prediction_use_case.dart';
import '../../../../domain/entities/no_show_prediction.dart';

abstract class AdminPatientsState {}
class AdminPatientsInitial extends AdminPatientsState {}
class AdminPatientsLoading extends AdminPatientsState {}
class AdminPatientsSuccess extends AdminPatientsState {
  final List<UserEntity> patients;
  final Map<String, NoShowPrediction> predictions;
  AdminPatientsSuccess(this.patients, {this.predictions = const {}});
}
class AdminPatientsFailure extends AdminPatientsState {
  final String message;
  AdminPatientsFailure(this.message);
}

@injectable
class AdminPatientsViewModel extends Cubit<AdminPatientsState> {
  final AuthRepo _authRepo;
  final AppointmentRepo _appointmentRepo;
  final GetNoShowPredictionUseCase _getNoShowPredictionUseCase;

  AdminPatientsViewModel(
    this._authRepo, 
    this._appointmentRepo,
    this._getNoShowPredictionUseCase
  ) : super(AdminPatientsInitial());

  void getAllPatients() async {
    emit(AdminPatientsLoading());
    try {
      final patients = await _authRepo.getAllPatients();
      emit(AdminPatientsSuccess(patients));
      _loadPredictionsForPatients(patients);
    } catch (e) {
      emit(AdminPatientsFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  void _loadPredictionsForPatients(List<UserEntity> patients) async {
    final Map<String, NoShowPrediction> currentPredictions = {};

    for (var patient in patients) {
      if (patient.uid.isEmpty) continue;

      try {
        final appointments = await _appointmentRepo
            .getPatientAppointments(patient.uid)
            .first
            .timeout(const Duration(seconds: 5), onTimeout: () => []);
        
        int total = appointments.length;
        
        // Flexible check: looks for "cancel" anywhere in the status string
        int cancelled = appointments.where((a) {
          final status = a.status?.toLowerCase() ?? "";
          return status.contains("cancel"); 
        }).length;

        // DEBUG: Check your console for these numbers!
        print("DEBUG: Patient: ${patient.fullName} | Total: $total | Cancelled: $cancelled");

        if (total > 0) {
          final prediction = await _getNoShowPredictionUseCase
              .execute(patient.uid, total, cancelled)
              .timeout(const Duration(seconds: 5));
          
          currentPredictions[patient.uid] = prediction;
        } else {
          currentPredictions[patient.uid] = NoShowPrediction(probability: 0, patientId: patient.uid);
        }
      } catch (e) {
        print("AI Error for ${patient.fullName}: $e");
        currentPredictions[patient.uid] = NoShowPrediction(probability: 0, patientId: patient.uid);
      }

      if (state is AdminPatientsSuccess) {
        final currentState = state as AdminPatientsSuccess;
        emit(AdminPatientsSuccess(currentState.patients, predictions: Map.from(currentPredictions)));
      }
    }
  }
}
