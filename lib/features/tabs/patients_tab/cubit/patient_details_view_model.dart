import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/medical_record_entity.dart';
import '../../../../domain/use_cases/get_medical_records_use_case.dart';

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

@injectable
class PatientDetailsViewModel extends Cubit<PatientDetailsState> {
  final GetMedicalRecordsUseCase _getMedicalRecordsUseCase;
  StreamSubscription? _subscription;

  PatientDetailsViewModel(this._getMedicalRecordsUseCase) : super(PatientDetailsInitial());

  void getMedicalRecords(String patientName) {
    emit(PatientDetailsLoading());
    _subscription?.cancel();
    _subscription = _getMedicalRecordsUseCase.call(patientName).listen(
      (records) {
        if (!isClosed) emit(PatientDetailsSuccess(records));
      },
      onError: (error) {
        if (!isClosed) emit(PatientDetailsFailure(error.toString()));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
