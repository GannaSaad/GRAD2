import '../entities/request_entity.dart';

abstract class RequestRepo {
  Stream<List<RequestEntity>> getRequests(String doctorId);
  Future<void> addRequest(RequestEntity request);
  Future<void> updateRequestStatus(String requestId, String status);
}
