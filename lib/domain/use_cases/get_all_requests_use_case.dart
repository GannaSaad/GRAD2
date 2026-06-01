import 'package:injectable/injectable.dart';
import '../entities/request_entity.dart';
import '../repos/request_repo.dart';

@injectable
class GetAllRequestsUseCase {
  final RequestRepo _repository;

  GetAllRequestsUseCase(this._repository);

  Stream<List<RequestEntity>> call() {
    return _repository.getAllRequests();
  }
}
