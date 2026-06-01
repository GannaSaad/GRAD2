import 'package:json_annotation/json_annotation.dart';

part 'chat_response.g.dart';

@JsonSerializable()
class ChatResponse {
  final String reply;
  
  @JsonKey(name: 'disease_context')
  final String? diseaseContext; // FIXED: Added this field

  ChatResponse({required this.reply, this.diseaseContext});

  factory ChatResponse.fromJson(Map<String, dynamic> json) => _$ChatResponseFromJson(json);
  
  Map<String, dynamic> toJson() => _$ChatResponseToJson(this);
}
