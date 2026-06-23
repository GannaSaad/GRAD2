import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/medical_record_entity.dart';
import '../../../../domain/use_cases/get_medical_records_use_case.dart';
import '../../../../domain/use_cases/save_medical_record_use_case.dart';
import '../../../../core/core/utils/firebase_storage_utils.dart';

abstract class PatientDetailsState {}
class PatientDetailsInitial extends PatientDetailsState {}
class PatientDetailsLoading extends PatientDetailsState {}
class PatientDetailsSuccess extends PatientDetailsState {
  final List<MedicalRecordEntity> records;
  PatientDetailsSuccess(this.records);
}
class PatientDetailsFailure extends PatientDetailsState {
  final String message;
  PatientDetailsFailure(this.message);
}
class PatientDetailsSaveSuccess extends PatientDetailsState {
  final List<MedicalRecordEntity> records;
  PatientDetailsSaveSuccess(this.records);
}
class PatientDetailsUploadingImages extends PatientDetailsState {}

@injectable
class PatientDetailsViewModel extends Cubit<PatientDetailsState> {
  final GetMedicalRecordsUseCase _getMedicalRecordsUseCase;
  final SaveMedicalRecordUseCase _saveMedicalRecordUseCase;
  StreamSubscription? _subscription;
  List<MedicalRecordEntity> _currentRecords = [];

  PatientDetailsViewModel(
    this._getMedicalRecordsUseCase,
    this._saveMedicalRecordUseCase,
  ) : super(PatientDetailsInitial());

  void getMedicalRecords(String patientName) {
    emit(PatientDetailsLoading());
    _subscription?.cancel();
    _subscription = _getMedicalRecordsUseCase.call(patientName).listen(
      (records) {
        _currentRecords = records;
        if (!isClosed) emit(PatientDetailsSuccess(records));
      },
      onError: (error) {
        if (!isClosed) emit(PatientDetailsFailure(error.toString()));
      },
    );
  }

  Future<void> updateToothRecord({
    required String patientName,
    required int toothId,
    required String diagnosis,
    required String procedure,
    required String plan,
    required String status,
  }) async {
    try {
      final record = MedicalRecordEntity(
        patientName: patientName,
        toothId: toothId,
        toothDiagnosis: diagnosis,
        toothProcedure: procedure,
        toothPlan: plan,
        treatmentStatus: status,
        createdAt: DateTime.now(),
      );
      await _saveMedicalRecordUseCase.call(record);
      if (!isClosed) emit(PatientDetailsSaveSuccess(_currentRecords));
    } catch (e) {
      if (!isClosed) emit(PatientDetailsFailure(e.toString()));
    }
  }

  Future<void> uploadImages({
    required String patientName,
    List<File>? panoramicImages,
    List<File>? intraoralImages,
  }) async {
    try {
      print('🚀 Starting image upload process...');
      print('👤 Patient: $patientName');
      print('📸 Panoramic images: ${panoramicImages?.length ?? 0}');
      print('📸 Intraoral images: ${intraoralImages?.length ?? 0}');
      
      emit(PatientDetailsUploadingImages());
      
      final List<String> panoramicUrls = [];
      final List<String> intraoralUrls = [];

      // Upload panoramic images
      if (panoramicImages != null && panoramicImages.isNotEmpty) {
        print('📤 Uploading ${panoramicImages.length} panoramic images...');
        for (int i = 0; i < panoramicImages.length; i++) {
          final file = panoramicImages[i];
          print('  📷 Uploading panoramic image ${i + 1}/${panoramicImages.length}');
          final url = await FirebaseStorageUtils.uploadImage(file, 'panoramic_xrays');
          if (url != null) {
            panoramicUrls.add(url);
            print('  ✅ Success! URL: $url');
          } else {
            print('  ❌ Failed to upload panoramic image ${i + 1}');
          }
        }
      }

      // Upload intraoral images
      if (intraoralImages != null && intraoralImages.isNotEmpty) {
        print('📤 Uploading ${intraoralImages.length} intraoral images...');
        for (int i = 0; i < intraoralImages.length; i++) {
          final file = intraoralImages[i];
          print('  📷 Uploading intraoral image ${i + 1}/${intraoralImages.length}');
          final url = await FirebaseStorageUtils.uploadImage(file, 'intraoral_xrays');
          if (url != null) {
            intraoralUrls.add(url);
            print('  ✅ Success! URL: $url');
          } else {
            print('  ❌ Failed to upload intraoral image ${i + 1}');
          }
        }
      }

      print('✅ Upload complete!');
      print('📊 Panoramic URLs: ${panoramicUrls.length}');
      print('📊 Intraoral URLs: ${intraoralUrls.length}');
      
      if (panoramicUrls.isEmpty && intraoralUrls.isEmpty) {
        throw Exception('No images were uploaded successfully. Check Firebase Storage permissions.');
      }

      // Save record with images
      print('💾 Saving record to Firestore...');
      final record = MedicalRecordEntity(
        patientName: patientName,
        panoramicImages: panoramicUrls.isEmpty ? null : panoramicUrls,
        intraoralImages: intraoralUrls.isEmpty ? null : intraoralUrls,
        createdAt: DateTime.now(),
      );
      
      await _saveMedicalRecordUseCase.call(record);
      print('✅ Record saved to Firestore!');
      
      // Wait a bit for Firestore to update, then refresh
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Force refresh to show new images
      print('🔄 Refreshing records...');
      getMedicalRecords(patientName);
    } catch (e, stackTrace) {
      print('❌ Upload error: $e');
      print('Stack trace: $stackTrace');
      if (!isClosed) emit(PatientDetailsFailure('Failed to upload images: $e'));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
