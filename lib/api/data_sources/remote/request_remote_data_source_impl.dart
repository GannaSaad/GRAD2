import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../../data/data_sources/remote/request_remote_data_source.dart';
import '../../../../data/models/request_model.dart';

@Injectable(as: RequestRemoteDataSource)
class RequestRemoteDataSourceImpl implements RequestRemoteDataSource {
  final FirebaseFirestore _firestore;

  RequestRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<RequestModel>> getRequests(String doctorId) {
    return _firestore
        .collection('supplies_requests')
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RequestModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  @override
  Stream<List<RequestModel>> getAllRequests() {
    return _firestore
        .collection('supplies_requests')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => RequestModel.fromFirestore(doc.data(), doc.id))
        .toList());
  }

  @override
  Future<void> addRequest(RequestModel request) async {
    try {
      await _firestore
          .collection('supplies_requests')
          .add(request.toFirestore());
    } catch (e) {
      throw Exception('Failed to add request: ${e.toString()}');
    }
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      await _firestore
          .collection('supplies_requests')
          .doc(requestId)
          .update({'status': status});
    } catch (e) {
      throw Exception('Failed to update request: ${e.toString()}');
    }
  }
}
