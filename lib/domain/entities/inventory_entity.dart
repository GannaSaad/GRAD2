import 'package:equatable/equatable.dart';

class InventoryEntity extends Equatable {
  final String id;
  final String name;
  final String unit;
  final int currentQuantity;
  final int totalQuantity;
  final String status; // 'In Stock', 'Low Stock', 'Out of Stock'

  const InventoryEntity({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.totalQuantity,
    required this.status,
  });

  @override
  List<Object?> get props => [id, name, unit, currentQuantity, totalQuantity, status];
}
