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
      emit(PatientDetailsUploadingImages());
      
      final List<String> panoramicUrls = [];
      final List<String> intraoralUrls = [];

      // Upload panoramic images
      if (panoramicImages != null && panoramicImages.isNotEmpty) {
        for (var file in panoramicImages) {
          final url = await FirebaseStorageUtils.uploadImage(file, 'panoramic_xrays');
          if (url != null) panoramicUrls.add(url);
        }
      }

      // Upload intraoral images
      if (intraoralImages != null && intraoralImages.isNotEmpty) {
        for (var file in intraoralImages) {
          final url = await FirebaseStorageUtils.uploadImage(file, 'intraoral_xrays');
          if (url != null) intraoralUrls.add(url);
        }
      }

      // Save record with images
      final record = MedicalRecordEntity(
        patientName: patientName,
        panoramicImages: panoramicUrls.isEmpty ? null : panoramicUrls,
        intraoralImages: intraoralUrls.isEmpty ? null : intraoralUrls,
        createdAt: DateTime.now(),
      );
      
      await _saveMedicalRecordUseCase.call(record);
      
      // Don't emit success here, let the stream listener update the records
      // The getMedicalRecords stream will automatically pick up the new record
    } catch (e) {
      if (!isClosed) emit(PatientDetailsFailure(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
