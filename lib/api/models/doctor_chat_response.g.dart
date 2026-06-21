// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_chat_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorChatResponse _$DoctorChatResponseFromJson(Map<String, dynamic> json) =>
    DoctorChatResponse(
      response: json['response'] as String,
      model: json['model'] as String?,
      type: json['type'] as String?,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DoctorChatResponseToJson(DoctorChatResponse instance) =>
    <String, dynamic>{
      'response': instance.response,
      'model': instance.model,
      'type': instance.type,
      'error': instance.error,
    };
