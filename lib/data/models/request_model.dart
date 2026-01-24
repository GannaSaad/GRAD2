import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request_entity.dart';

class RequestModel {
  final String id;
  final String itemName;
  final int quantity;
  final String supplier;
  final String status;
  final DateTime date;
  final String doctorId;

  RequestModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.supplier,
    required this.status,
    required this.date,
    required this.doctorId,
  });

  factory RequestModel.fromFirestore(Map<String, dynamic> json, String id) {
    return RequestModel(
      id: id,
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      supplier: json['supplier'] ?? '',
      status: json['status'] ?? 'Pending',
      date: (json['date'] as Timestamp).toDate(),
      doctorId: json['doctorId'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'supplier': supplier,
      'status': status,
      'date': Timestamp.fromDate(date),
      'doctorId': doctorId,
    };
  }

  RequestEntity toEntity() {
    return RequestEntity(
      id: id,
      itemName: itemName,
      quantity: quantity,
      supplier: supplier,
      status: status,
      date: date,
      doctorId: doctorId,
    );
  }

  factory RequestModel.fromEntity(RequestEntity entity) {
    return RequestModel(
      id: entity.id,
      itemName: entity.itemName,
      quantity: entity.quantity,
      supplier: entity.supplier,
      status: entity.status,
      date: entity.date,
      doctorId: entity.doctorId,
    );
  }
}
