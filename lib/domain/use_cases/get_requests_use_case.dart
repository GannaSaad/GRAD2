import 'package:injectable/injectable.dart';
import '../entities/request_entity.dart';
import '../repos/request_repo.dart';

@injectable
class GetRequestsUseCase {
  final RequestRepo _repository;

  GetRequestsUseCase(this._repository);

  Stream<List<RequestEntity>> call(String doctorId) {
    return _repository.getRequests(doctorId);
  }
}
