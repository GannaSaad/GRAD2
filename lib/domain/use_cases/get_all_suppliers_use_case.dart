import 'package:injectable/injectable.dart';
import '../entities/user_entity.dart';
import '../repos/auth_repo.dart';

@injectable
class GetAllSuppliersUseCase {
  final AuthRepo _repository;

  GetAllSuppliersUseCase(this._repository);

  Future<List<UserEntity>> call() {
    return _repository.getAllSuppliers();
  }
}
