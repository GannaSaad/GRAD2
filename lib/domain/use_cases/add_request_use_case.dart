import 'package:injectable/injectable.dart';
import '../entities/request_entity.dart';
import '../repos/request_repo.dart';

@injectable
class AddRequestUseCase {
  final RequestRepo _repository;

  AddRequestUseCase(this._repository);

  Future<void> call(RequestEntity request) {
    return _repository.addRequest(request);
  }
}
