import '../entities/medical_record_entity.dart';

abstract class MedicalRecordRepo {
  Future<void> saveMedicalRecord(MedicalRecordEntity record);
  Stream<List<MedicalRecordEntity>> getMedicalRecords(String patientName);
}
