import 'package:json_annotation/json_annotation.dart';
part 'prediction_response.g.dart';

@JsonSerializable()
class PredictionResponse {
  final double probability;
  final String status;

  PredictionResponse(this.probability, this.status);

  factory PredictionResponse.fromJson(Map<String, dynamic> json) =>
      _$PredictionResponseFromJson(json);
}
