import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';
import '../../../data/models/inventory_model.dart';

abstract class InventoryRemoteDataSource {
  Stream<List<InventoryModel>> getInventory();
  Future<void> addInventoryItem(InventoryModel item);
  Future<void> updateInventoryQuantity(String itemId, int newQuantity);
}

@Injectable(as: InventoryRemoteDataSource)
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final FirebaseFirestore _firestore;

  InventoryRemoteDataSourceImpl(this._firestore);

  @override
  Stream<List<InventoryModel>> getInventory() {
    return _firestore.collection('inventory').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => InventoryModel.fromFirestore(doc.data(), doc.id)).toList();
    });
  }

  @override
  Future<void> addInventoryItem(InventoryModel item) async {
    await _firestore.collection('inventory').doc(item.id).set(item.toFirestore());
  }

  @override
  Future<void> updateInventoryQuantity(String itemId, int newQuantity) async {
    String status = 'In Stock';
    // Fetch total quantity to determine status
    final doc = await _firestore.collection('inventory').doc(itemId).get();
    if (doc.exists) {
      final total = doc.data()?['totalQuantity'] ?? 100;
      if (newQuantity == 0) {
        status = 'Out of Stock';
      } else if (newQuantity < (total * 0.2)) {
        status = 'Low Stock';
      }
    }

    await _firestore.collection('inventory').doc(itemId).update({
      'currentQuantity': newQuantity,
      'status': status,
    });
  }
}
