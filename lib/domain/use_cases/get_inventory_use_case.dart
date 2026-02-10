import 'package:injectable/injectable.dart';
import '../entities/inventory_entity.dart';
import '../repos/inventory_repo.dart';

@injectable
class GetInventoryUseCase {
  final InventoryRepo _repository;

  GetInventoryUseCase(this._repository);

  Stream<List<InventoryEntity>> call() {
    return _repository.getInventory();
  }
}
