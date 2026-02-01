import 'package:injectable/injectable.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/no_show_prediction.dart';
import '../../domain/repos/prediction_repo.dart';
import '../../api/web_services.dart';

@Injectable(as: PredictionRepo)
class PredictionRepoImpl implements PredictionRepo {
  final WebServices _webServices;

  PredictionRepoImpl(this._webServices);

  @override
  Future<NoShowPrediction> getPrediction(
      String patientId,
      int appointments,
      int cancellations
      ) async {
    try {
      final response = await _webServices.getNoShowPrediction(appointments, cancellations);

      return NoShowPrediction(
        probability: response.probability ?? 0.0,
        patientId: patientId.isEmpty ? "unknown_patient" : patientId,
        appointments: appointments,
        cancellations: cancellations,
        pending: (appointments - cancellations) < 0 ? 0 : (appointments - cancellations),
      );
    } catch (e) {
      debugPrint("PREDICTION ERROR for Patient $patientId: ${e.toString()}");

      // Fallback object so the UI doesn't crash if the internet fails
      return NoShowPrediction(
        probability: 0.0,
        patientId: patientId,
        appointments: appointments,
        cancellations: cancellations,
        pending: 0,
      );
    }
  }
}