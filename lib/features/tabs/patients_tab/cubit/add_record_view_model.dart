import 'dart:convert';
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/medical_record_entity.dart';
import '../../../../domain/use_cases/save_medical_record_use_case.dart';

abstract class AddRecordState {}
class AddRecordInitial extends AddRecordState {}
class AddRecordLoading extends AddRecordState {}
class AddRecordSuccess extends AddRecordState {}
class AddRecordFailure extends AddRecordState {
  final String message;
  AddRecordFailure(this.message);
}

@injectable
class AddRecordViewModel extends Cubit<AddRecordState> {
  final SaveMedicalRecordUseCase _saveMedicalRecordUseCase;

  AddRecordViewModel(this._saveMedicalRecordUseCase) : super(AddRecordInitial());

  Future<void> saveRecord({
    required String patientName,
    int? toothId,
    String? toothDiagnosis,
    String? toothProcedure,
    String? toothPlan,
    String? treatmentStatus,
    String? prescription,
    String? generalNotes,
    List<File>? panoramicImages,
    List<File>? intraoralImages,
  }) async {
    emit(AddRecordLoading());
    try {
      // Convert Files to Base64 Strings for Firestore storage (Workaround for no Firebase Storage)
      List<String>? panoramicBase64;
      if (panoramicImages != null && panoramicImages.isNotEmpty) {
        panoramicBase64 = panoramicImages.map((file) {
          final bytes = file.readAsBytesSync();
          return base64Encode(bytes);
        }).toList();
      }

      List<String>? intraoralBase64;
      if (intraoralImages != null && intraoralImages.isNotEmpty) {
        intraoralBase64 = intraoralImages.map((file) {
          final bytes = file.readAsBytesSync();
          return base64Encode(bytes);
        }).toList();
      }

      final record = MedicalRecordEntity(
        patientName: patientName,
        toothId: toothId,
        toothDiagnosis: toothDiagnosis,
        toothProcedure: toothProcedure,
        toothPlan: toothPlan,
        treatmentStatus: treatmentStatus,
        prescription: prescription,
        generalNotes: generalNotes,
        panoramicImages: panoramicBase64,
        intraoralImages: intraoralBase64,
        createdAt: DateTime.now(),
      );
      
      await _saveMedicalRecordUseCase.call(record);
      emit(AddRecordSuccess());
    } catch (e) {
      emit(AddRecordFailure(e.toString()));
    }
  }
}
