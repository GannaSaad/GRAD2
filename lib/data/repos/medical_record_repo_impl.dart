import 'package:injectable/injectable.dart';
import '../../api/data_sources/remote/medical_record_remote_data_source_impl.dart';
import '../../domain/entities/medical_record_entity.dart';
import '../../domain/repos/medical_record_repo.dart';
import '../models/medical_record_model.dart';

@Injectable(as: MedicalRecordRepo)
class MedicalRecordRepoImpl implements MedicalRecordRepo {
  final MedicalRecordRemoteDataSource _remoteDataSource;

  MedicalRecordRepoImpl(this._remoteDataSource);

  @override
  Future<void> saveMedicalRecord(MedicalRecordEntity record) {
    return _remoteDataSource.saveMedicalRecord(MedicalRecordModel.fromEntity(record));
  }

  @override
  Stream<List<MedicalRecordEntity>> getMedicalRecords(String patientName) {
    return _remoteDataSource.getMedicalRecords(patientName).map(
          (list) => list.map((model) => model.toEntity()).toList(),
        );
  }
}
