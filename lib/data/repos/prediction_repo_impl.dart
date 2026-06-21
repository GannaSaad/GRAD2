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
      // Prepare JSON body for POST request to port 8002
      final body = {
        'appointments': appointments,
        'cancellations': cancellations,
      };
      
      // DEBUG: Print what we're sending
      debugPrint("=" * 50);
      debugPrint("🔍 SENDING PREDICTION REQUEST:");
      debugPrint("  Patient ID: $patientId");
      debugPrint("  Appointments: $appointments (${appointments.runtimeType})");
      debugPrint("  Cancellations: $cancellations (${cancellations.runtimeType})");
      debugPrint("  Body: $body");
      debugPrint("=" * 50);
      
      final response = await _webServices.getNoShowPrediction(body);
      
      // DEBUG: Print response
      debugPrint("✅ PREDICTION RESPONSE:");
      debugPrint("  Probability: ${response.probability}");
      debugPrint("  Status: ${response.status}");
      debugPrint("=" * 50);

      return NoShowPrediction(
        probability: response.probability ?? 0.0,
        patientId: patientId.isEmpty ? "unknown_patient" : patientId,
        appointments: appointments,
        cancellations: cancellations,
        pending: (appointments - cancellations) < 0 ? 0 : (appointments - cancellations),
      );
    } catch (e) {
      debugPrint("=" * 50);
      debugPrint("❌ PREDICTION ERROR for Patient $patientId");
      debugPrint("Error type: ${e.runtimeType}");
      debugPrint("Error message: ${e.toString()}");
      debugPrint("=" * 50);

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