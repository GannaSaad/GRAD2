import '../entities/no_show_prediction.dart';

abstract class PredictionRepo {
  Future<NoShowPrediction> getPrediction(String patientId, int appointments, int cancellations);
}
