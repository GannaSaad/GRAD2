import 'package:injectable/injectable.dart';
import '../../domain/entities/no_show_prediction.dart';
import '../../domain/repos/prediction_repo.dart';
import '../../api/web_services.dart';

@Injectable(as: PredictionRepo)
class PredictionRepoImpl implements PredictionRepo {
  final WebServices _webServices;

  PredictionRepoImpl(this._webServices);

  @override
  Future<NoShowPrediction> getPrediction(String patientId, int appointments, int cancellations) async {
    // Updated to call the new getNoShowPrediction method
    final response = await _webServices.getNoShowPrediction(appointments, cancellations);
    return NoShowPrediction(
      probability: response.probability,
      patientId: patientId,
    );
  }
}
