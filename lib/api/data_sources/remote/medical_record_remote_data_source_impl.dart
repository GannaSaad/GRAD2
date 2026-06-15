import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/medical_record_model.dart';

abstract class MedicalRecordRemoteDataSource {
  Future<void> saveMedicalRecord(MedicalRecordModel record);
  Stream<List<MedicalRecordModel>> getMedicalRecords(String patientName);
}

@Injectable(as: MedicalRecordRemoteDataSource)
class MedicalRecordRemoteDataSourceImpl implements MedicalRecordRemoteDataSource {
  final FirebaseFirestore _firestore;

  MedicalRecordRemoteDataSourceImpl(this._firestore);

  @override
  Future<void> saveMedicalRecord(MedicalRecordModel record) async {
    try {
      await _firestore
          .collection('medical_records')
          .add(record.toFirestore());
    } catch (e) {
      throw Exception('Failed to save medical record: ${e.toString()}');
    }
  }

  @override
  Stream<List<MedicalRecordModel>> getMedicalRecords(String patientName) {
    return _firestore
        .collection('medical_records')
        .where('patientName', isEqualTo: patientName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MedicalRecordModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }
}
