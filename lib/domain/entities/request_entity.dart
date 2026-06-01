import 'package:equatable/equatable.dart';

class RequestEntity extends Equatable {
  final String id;
  final String itemName;
  final int quantity;
  final String supplier; // This is the Company Name (e.g., "DentalCare Supplies")
  final String? supplierId; 
  final String status;
  final DateTime date;
  final String doctorId;
  final String? clinicName; // Name of the clinic/doctor requesting
  final String? notes;
  final DateTime? neededBy;

  const RequestEntity({
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

  @override
  List<Object?> get props => [
    id, 
    itemName, 
    quantity, 
    supplier, 
    supplierId,
    status, 
    date, 
    doctorId, 
    clinicName,
    notes, 
    neededBy
  ];

  RequestEntity copyWith({
    String? id,
    String? itemName,
    int? quantity,
    String? supplier,
    String? supplierId,
    String? status,
    DateTime? date,
    String? doctorId,
    String? clinicName,
    String? notes,
    DateTime? neededBy,
  }) {
    return RequestEntity(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      quantity: quantity ?? this.quantity,
      supplier: supplier ?? this.supplier,
      supplierId: supplierId ?? this.supplierId,
      status: status ?? this.status,
      date: date ?? this.date,
      doctorId: doctorId ?? this.doctorId,
      clinicName: clinicName ?? this.clinicName,
      notes: notes ?? this.notes,
      neededBy: neededBy ?? this.neededBy,
    );
  }
}
