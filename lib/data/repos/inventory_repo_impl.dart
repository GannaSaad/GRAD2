import 'package:injectable/injectable.dart';
import '../../api/data_sources/remote/inventory_remote_data_source_impl.dart';
import '../../domain/entities/inventory_entity.dart';
import '../../domain/repos/inventory_repo.dart';
import '../models/inventory_model.dart';

@Injectable(as: InventoryRepo)
class InventoryRepoImpl implements InventoryRepo {
  final InventoryRemoteDataSource _remoteDataSource;

  InventoryRepoImpl(this._remoteDataSource);

  @override
  Stream<List<InventoryEntity>> getInventory() {
    return _remoteDataSource.getInventory().map(
          (list) => list.map((model) => model.toEntity()).toList(),
        );
  }

  @override
  Future<void> addInventoryItem(InventoryEntity item) {
    return _remoteDataSource.addInventoryItem(InventoryModel.fromEntity(item));
  }

  @override
  Future<void> updateInventoryQuantity(String itemId, int newQuantity) {
    return _remoteDataSource.updateInventoryQuantity(itemId, newQuantity);
  }
}
