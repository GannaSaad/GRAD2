// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_clinical_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DoctorClinicalResponse _$DoctorClinicalResponseFromJson(
        Map<String, dynamic> json) =>
    DoctorClinicalResponse(
      answer: json['answer'] as String?,
      status: json['status'] as String,
      error: json['error'] as String?,
    );

Map<String, dynamic> _$DoctorClinicalResponseToJson(
        DoctorClinicalResponse instance) =>
    <String, dynamic>{
      'answer': instance.answer,
      'status': instance.status,
      'error': instance.error,
    };
