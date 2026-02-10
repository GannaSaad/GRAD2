import 'package:injectable/injectable.dart';
import '../repos/inventory_repo.dart';

@injectable
class DecrementInventoryUseCase {
  final InventoryRepo _repository;

  DecrementInventoryUseCase(this._repository);

  Future<void> call(String itemName, int quantity) async {
    try {
      final inventory = await _repository.getInventory().first;
      // Find the item using a case-insensitive search
      final item = inventory.firstWhere(
        (i) => i.name.toLowerCase().contains(itemName.toLowerCase()),
      );
      
      final newQuantity = item.currentQuantity - quantity;
      await _repository.updateInventoryQuantity(
        item.id, 
        newQuantity < 0 ? 0 : newQuantity
      );
    } catch (e) {
      // If the item doesn't exist in inventory, we skip it to prevent crashes
      print("Inventory Sync: Item '$itemName' not found in database.");
    }
  }
}
