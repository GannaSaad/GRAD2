import '../entities/inventory_entity.dart';

abstract class InventoryRepo {
  Stream<List<InventoryEntity>> getInventory();
  Future<void> addInventoryItem(InventoryEntity item);
  Future<void> updateInventoryQuantity(String itemId, int newQuantity);
}
