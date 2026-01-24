import 'package:injectable/injectable.dart';
import '../repos/request_repo.dart';

@injectable
class UpdateRequestStatusUseCase {
  final RequestRepo _repository;

  UpdateRequestStatusUseCase(this._repository);

  Future<void> call(String requestId, String status) {
    return _repository.updateRequestStatus(requestId, status);
  }
}
