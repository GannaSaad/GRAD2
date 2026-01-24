import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/inventory_entity.dart';
import '../../../../domain/repos/inventory_repo.dart';

abstract class InventoryState {}
class InventoryInitial extends InventoryState {}
class InventoryLoading extends InventoryState {}
class InventorySuccess extends InventoryState {
  final List<InventoryEntity> items;
  InventorySuccess(this.items);
}
class InventoryFailure extends InventoryState {
  final String message;
  InventoryFailure(this.message);
}

@injectable
class InventoryViewModel extends Cubit<InventoryState> {
  final InventoryRepo _inventoryRepo;
  StreamSubscription? _subscription;

  InventoryViewModel(this._inventoryRepo) : super(InventoryInitial());

  void getInventory() {
    emit(InventoryLoading());
    _subscription?.cancel();
    _subscription = _inventoryRepo.getInventory().listen(
      (items) {
        if (!isClosed) emit(InventorySuccess(items));
      },
      onError: (error) {
        if (!isClosed) emit(InventoryFailure(error.toString()));
      },
    );
  }

  Future<void> addItem(InventoryEntity item) async {
    try {
      await _inventoryRepo.addInventoryItem(item);
    } catch (e) {
      if (!isClosed) emit(InventoryFailure(e.toString()));
    }
  }

  Future<void> updateQuantity(String itemId, int newQuantity) async {
    try {
      await _inventoryRepo.updateInventoryQuantity(itemId, newQuantity);
    } catch (e) {
      if (!isClosed) emit(InventoryFailure(e.toString()));
    }
  }

  Future<void> seedInventoryIfEmpty() async {
    final firstBatch = await _inventoryRepo.getInventory().first;
    if (firstBatch.isEmpty) {
      final tools = [
        const InventoryEntity(id: "inv_1", name: "Latex Gloves (M)", unit: "Boxes", currentQuantity: 80, totalQuantity: 100, status: "In Stock"),
        const InventoryEntity(id: "inv_2", name: "Dental Mirror #4", unit: "Units", currentQuantity: 45, totalQuantity: 50, status: "In Stock"),
        const InventoryEntity(id: "inv_3", name: "Composite Resin (A2)", unit: "Capsules", currentQuantity: 40, totalQuantity: 50, status: "In Stock"),
        const InventoryEntity(id: "inv_4", name: "Anesthetic Vials", unit: "Vials", currentQuantity: 120, totalQuantity: 200, status: "In Stock"),
        const InventoryEntity(id: "inv_5", name: "Surgical Masks", unit: "Boxes", currentQuantity: 45, totalQuantity: 50, status: "In Stock"),
        const InventoryEntity(id: "inv_6", name: "High-Volume Suction", unit: "Tips", currentQuantity: 90, totalQuantity: 100, status: "In Stock"),
        const InventoryEntity(id: "inv_7", name: "Dental Bibs", unit: "Rolls", currentQuantity: 15, totalQuantity: 20, status: "In Stock"),
      ];
      for (var tool in tools) {
        await _inventoryRepo.addInventoryItem(tool);
      }
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
