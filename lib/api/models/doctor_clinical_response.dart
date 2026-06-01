import 'package:json_annotation/json_annotation.dart';

part 'doctor_clinical_response.g.dart';

@JsonSerializable()
class DoctorClinicalResponse {
  final String? answer;
  final String status;
  final String? error;

  DoctorClinicalResponse({this.answer, required this.status, this.error});

  factory DoctorClinicalResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorClinicalResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorClinicalResponseToJson(this);
}
