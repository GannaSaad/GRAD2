import 'package:equatable/equatable.dart';

class MedicalRecordEntity extends Equatable {
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

  const MedicalRecordEntity({
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

  @override
  List<Object?> get props => [
        id,
        patientName,
        toothId,
        toothDiagnosis,
        toothProcedure,
        toothPlan,
        treatmentStatus,
        prescription,
        generalNotes,
        panoramicImages,
        intraoralImages,
        createdAt,
      ];
}
