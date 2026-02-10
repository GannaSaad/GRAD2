import 'package:injectable/injectable.dart';
import '../../domain/entities/request_entity.dart';
import '../../domain/repos/request_repo.dart';
import '../data_sources/remote/request_remote_data_source.dart';
import '../models/request_model.dart';

@Injectable(as: RequestRepo)
class RequestRepoImpl implements RequestRepo {
  final RequestRemoteDataSource _remoteDataSource;

  RequestRepoImpl(this._remoteDataSource);

  @override
  Stream<List<RequestEntity>> getRequests(String doctorId) {
    return _remoteDataSource.getRequests(doctorId).map(
          (list) => list.map((model) => model.toEntity()).toList(),
    );
  }

  @override
  Future<void> addRequest(RequestEntity request) {
    return _remoteDataSource.addRequest(RequestModel.fromEntity(request));
  }

  @override
  Future<void> updateRequestStatus(String requestId, String status) {
    return _remoteDataSource.updateRequestStatus(requestId, status);
  }
}