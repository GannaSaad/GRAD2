import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/medical_record_entity.dart';
import '../../../../domain/use_cases/save_medical_record_use_case.dart'; // Corrected import
import '../../../../core/core/utils/firebase_storage_utils.dart';

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
  final SaveMedicalRecordUseCase _saveMedicalRecordUseCase; // Corrected type

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
      final List<String> panoramicUrls = [];
      final List<String> intraoralUrls = [];

      // 1. UPLOAD PANORAMIC TO STORAGE
      if (panoramicImages != null && panoramicImages.isNotEmpty) {
        for (var file in panoramicImages) {
          final url = await FirebaseStorageUtils.uploadImage(file, 'panoramic_xrays');
          if (url != null) panoramicUrls.add(url);
        }
      }

      // 2. UPLOAD INTRAORAL TO STORAGE
      if (intraoralImages != null && intraoralImages.isNotEmpty) {
        for (var file in intraoralImages) {
          final url = await FirebaseStorageUtils.uploadImage(file, 'intraoral_xrays');
          if (url != null) intraoralUrls.add(url);
        }
      }

      // 3. CREATE ENTITY WITH STORAGE URLS
      final record = MedicalRecordEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        patientName: patientName,
        toothId: toothId,
        toothDiagnosis: toothDiagnosis,
        toothProcedure: toothProcedure,
        toothPlan: toothPlan,
        treatmentStatus: treatmentStatus,
        prescription: prescription,
        generalNotes: generalNotes,
        panoramicImages: panoramicUrls,
        intraoralImages: intraoralUrls,
        createdAt: DateTime.now(),
      );

      await _saveMedicalRecordUseCase.call(record); // Corrected call
      emit(AddRecordSuccess());
    } catch (e) {
      emit(AddRecordFailure(e.toString()));
    }
  }
}
