import 'package:json_annotation/json_annotation.dart';

part 'doctor_chat_response.g.dart';

@JsonSerializable()
class DoctorChatResponse {
  final String response;
  final String? model;
  final String? type;
  final String? error;

  DoctorChatResponse({
    required this.response,
    this.model,
    this.type,
    this.error,
  });

  factory DoctorChatResponse.fromJson(Map<String, dynamic> json) =>
      _$DoctorChatResponseFromJson(json);

  Map<String, dynamic> toJson() => _$DoctorChatResponseToJson(this);
}
