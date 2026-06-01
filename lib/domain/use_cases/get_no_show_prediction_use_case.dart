import 'package:injectable/injectable.dart';
import '../entities/no_show_prediction.dart';
import '../repos/prediction_repo.dart';

@injectable
class GetNoShowPredictionUseCase {
  final PredictionRepo _repository;

  GetNoShowPredictionUseCase(this._repository);

  Future<NoShowPrediction> execute(String patientId, int appointments, int cancellations) {
    return _repository.getPrediction(patientId, appointments, cancellations);
  }
}
