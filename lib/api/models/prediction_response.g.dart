// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'prediction_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PredictionResponse _$PredictionResponseFromJson(Map<String, dynamic> json) =>
    PredictionResponse(
      probability: (json['probability'] as num?)?.toDouble(),
      status: json['status'] as String?,
    );

Map<String, dynamic> _$PredictionResponseToJson(PredictionResponse instance) =>
    <String, dynamic>{
      'probability': instance.probability,
      'status': instance.status,
    };
