import '../../domain/entities/inventory_entity.dart';

class InventoryModel {
  final String id;
  final String name;
  final String unit;
  final int currentQuantity;
  final int totalQuantity;
  final String status;

  InventoryModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.currentQuantity,
    required this.totalQuantity,
    required this.status,
  });

  factory InventoryModel.fromFirestore(Map<String, dynamic> json, String id) {
    return InventoryModel(
      id: id,
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      currentQuantity: json['currentQuantity'] ?? 0,
      totalQuantity: json['totalQuantity'] ?? 0,
      status: json['status'] ?? 'In Stock',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'unit': unit,
      'currentQuantity': currentQuantity,
      'totalQuantity': totalQuantity,
      'status': status,
    };
  }

  InventoryEntity toEntity() {
    return InventoryEntity(
      id: id,
      name: name,
      unit: unit,
      currentQuantity: currentQuantity,
      totalQuantity: totalQuantity,
      status: status,
    );
  }

  factory InventoryModel.fromEntity(InventoryEntity entity) {
    return InventoryModel(
      id: entity.id,
      name: entity.name,
      unit: entity.unit,
      currentQuantity: entity.currentQuantity,
      totalQuantity: entity.totalQuantity,
      status: entity.status,
    );
  }
}
