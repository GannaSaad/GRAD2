import 'package:injectable/injectable.dart';
import '../entities/medical_record_entity.dart';
import '../repos/medical_record_repo.dart';

@injectable
class GetMedicalRecordsUseCase {
  final MedicalRecordRepo _repository;

  GetMedicalRecordsUseCase(this._repository);

  Stream<List<MedicalRecordEntity>> call(String patientName) {
    return _repository.getMedicalRecords(patientName);
  }
}
