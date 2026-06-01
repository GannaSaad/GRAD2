import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/request_entity.dart';

class RequestModel {
  final String id;
  final String itemName;
  final int quantity;
  final String supplier;
  final String? supplierId;
  final String status;
  final DateTime date;
  final String doctorId;
  final String? clinicName; // Name of the clinic/doctor requesting
  final String? notes;
  final DateTime? neededBy;

  RequestModel({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.supplier,
    this.supplierId,
    required this.status,
    required this.date,
    required this.doctorId,
    this.clinicName,
    this.notes,
    this.neededBy,
  });

  factory RequestModel.fromFirestore(Map<String, dynamic> json, String id) {
    return RequestModel(
      id: id,
      itemName: json['itemName'] ?? '',
      quantity: json['quantity'] ?? 0,
      supplier: json['supplier'] ?? '',
      supplierId: json['supplierId'],
      status: json['status'] ?? 'Pending',
      date: (json['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      doctorId: json['doctorId'] ?? '',
      clinicName: json['clinicName'],
      notes: json['notes'],
      neededBy: (json['neededBy'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'itemName': itemName,
      'quantity': quantity,
      'supplier': supplier,
      'supplierId': supplierId,
      'status': status,
      'date': Timestamp.fromDate(date),
      'doctorId': doctorId,
      'clinicName': clinicName,
      'notes': notes,
      'neededBy': neededBy != null ? Timestamp.fromDate(neededBy!) : null,
    };
  }

  RequestEntity toEntity() {
    return RequestEntity(
      id: id,
      itemName: itemName,
      quantity: quantity,
      supplier: supplier,
      supplierId: supplierId,
      status: status,
      date: date,
      doctorId: doctorId,
      clinicName: clinicName,
      notes: notes,
      neededBy: neededBy,
    );
  }

  factory RequestModel.fromEntity(RequestEntity entity) {
    return RequestModel(
      id: entity.id,
      itemName: entity.itemName,
      quantity: entity.quantity,
      supplier: entity.supplier,
      supplierId: entity.supplierId,
      status: entity.status,
      date: entity.date,
      doctorId: entity.doctorId,
      clinicName: entity.clinicName,
      notes: entity.notes,
      neededBy: entity.neededBy,
    );
  }
}
