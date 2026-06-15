import '../../models/request_model.dart';

abstract class RequestRemoteDataSource {
  Stream<List<RequestModel>> getRequests(String doctorId);
  Stream<List<RequestModel>> getAllRequests();
  Future<void> addRequest(RequestModel request);
  Future<void> updateRequestStatus(String requestId, String status);
}
