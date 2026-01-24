import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../domain/entities/inventory_entity.dart';
import '../../../../domain/use_cases/decrement_inventory_use_case.dart';
import '../../../../domain/use_cases/get_inventory_use_case.dart';

abstract class ClinicalPrepState {}
class ClinicalPrepInitial extends ClinicalPrepState {}
class ClinicalPrepLoading extends ClinicalPrepState {}
class ClinicalPrepSuccess extends ClinicalPrepState {
  final List<InventoryEntity> inventory;
  final Set<String> pickedItemIds;
  ClinicalPrepSuccess(this.inventory, this.pickedItemIds);
}
class ClinicalPrepFailure extends ClinicalPrepState {
  final String message;
  ClinicalPrepFailure(this.message);
}

@injectable
class ClinicalPrepViewModel extends Cubit<ClinicalPrepState> {
  final DecrementInventoryUseCase _decrementInventoryUseCase;
  final GetInventoryUseCase _getInventoryUseCase;
  StreamSubscription? _inventorySubscription;
  
  List<InventoryEntity> _allInventory = [];
  final Set<String> _pickedItemIds = {};

  ClinicalPrepViewModel(
    this._decrementInventoryUseCase,
    this._getInventoryUseCase,
  ) : super(ClinicalPrepInitial());

  void loadInventory() {
    emit(ClinicalPrepLoading());
    _inventorySubscription?.cancel();
    _inventorySubscription = _getInventoryUseCase.call().listen(
      (items) {
        _allInventory = items;
        // Ensure success state is emitted even if items list is empty
        if (!isClosed) {
          emit(ClinicalPrepSuccess(List.from(_allInventory), Set.from(_pickedItemIds)));
        }
      },
      onError: (e) {
        if (!isClosed) emit(ClinicalPrepFailure(e.toString()));
      },
    );
  }

  void togglePick(String itemId) {
    if (_pickedItemIds.contains(itemId)) {
      _pickedItemIds.remove(itemId);
    } else {
      _pickedItemIds.add(itemId);
    }
    emit(ClinicalPrepSuccess(List.from(_allInventory), Set.from(_pickedItemIds)));
  }

  Future<void> confirmReadiness() async {
    final prevState = state;
    emit(ClinicalPrepLoading());
    try {
      for (var itemId in _pickedItemIds) {
        final item = _allInventory.firstWhere((i) => i.id == itemId);
        await _decrementInventoryUseCase.call(item.name, 1);
      }
      _pickedItemIds.clear();
      // Reset after successful deduction
      emit(ClinicalPrepInitial()); 
    } catch (e) {
      emit(ClinicalPrepFailure(e.toString()));
      if (prevState is ClinicalPrepSuccess) emit(prevState);
    }
  }

  @override
  Future<void> close() {
    _inventorySubscription?.cancel();
    return super.close();
  }
}
