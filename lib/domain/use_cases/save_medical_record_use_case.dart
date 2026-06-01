import 'package:injectable/injectable.dart';
import '../entities/medical_record_entity.dart';
import '../repos/medical_record_repo.dart';

@injectable
class SaveMedicalRecordUseCase {
  final MedicalRecordRepo _repository;

  SaveMedicalRecordUseCase(this._repository);

  Future<void> call(MedicalRecordEntity record) {
    return _repository.saveMedicalRecord(record);
  }
}
