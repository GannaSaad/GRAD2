import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/medical_record_entity.dart';

class MedicalRecordModel {
  final String? id;
  final String patientName;
  final int? toothId;
  final String? toothDiagnosis;
  final String? toothProcedure;
  final String? toothPlan;
  final String? treatmentStatus;
  final String? prescription;
  final String? generalNotes;
  final List<String>? panoramicImages;
  final List<String>? intraoralImages;
  final DateTime createdAt;

  MedicalRecordModel({
    this.id,
    required this.patientName,
    this.toothId,
    this.toothDiagnosis,
    this.toothProcedure,
    this.toothPlan,
    this.treatmentStatus,
    this.prescription,
    this.generalNotes,
    this.panoramicImages,
    this.intraoralImages,
    required this.createdAt,
  });

  factory MedicalRecordModel.fromFirestore(Map<String, dynamic> json, String id) {
    return MedicalRecordModel(
      id: id,
      patientName: json['patientName'] ?? '',
      toothId: json['toothId'],
      toothDiagnosis: json['toothDiagnosis'],
      toothProcedure: json['toothProcedure'],
      toothPlan: json['toothPlan'],
      treatmentStatus: json['treatmentStatus'],
      prescription: json['prescription'],
      generalNotes: json['generalNotes'],
      panoramicImages: json['panoramicImages'] != null ? List<String>.from(json['panoramicImages']) : null,
      intraoralImages: json['intraoralImages'] != null ? List<String>.from(json['intraoralImages']) : null,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'patientName': patientName,
      'toothId': toothId,
      'toothDiagnosis': toothDiagnosis,
      'toothProcedure': toothProcedure,
      'toothPlan': toothPlan,
      'treatmentStatus': treatmentStatus,
      'prescription': prescription,
      'generalNotes': generalNotes,
      'panoramicImages': panoramicImages,
      'intraoralImages': intraoralImages,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  MedicalRecordEntity toEntity() {
    return MedicalRecordEntity(
      id: id,
      patientName: patientName,
      toothId: toothId,
      toothDiagnosis: toothDiagnosis,
      toothProcedure: toothProcedure,
      toothPlan: toothPlan,
      treatmentStatus: treatmentStatus,
      prescription: prescription,
      generalNotes: generalNotes,
      panoramicImages: panoramicImages,
      intraoralImages: intraoralImages,
      createdAt: createdAt,
    );
  }

  factory MedicalRecordModel.fromEntity(MedicalRecordEntity entity) {
    return MedicalRecordModel(
      id: entity.id,
      patientName: entity.patientName,
      toothId: entity.toothId,
      toothDiagnosis: entity.toothDiagnosis,
      toothProcedure: entity.toothProcedure,
      toothPlan: entity.toothPlan,
      treatmentStatus: entity.treatmentStatus,
      prescription: entity.prescription,
      generalNotes: entity.generalNotes,
      panoramicImages: entity.panoramicImages,
      intraoralImages: entity.intraoralImages,
      createdAt: entity.createdAt,
    );
  }
}
