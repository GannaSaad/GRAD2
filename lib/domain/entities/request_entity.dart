import 'package:equatable/equatable.dart';

class RequestEntity extends Equatable {
  final String id;
  final String itemName;
  final int quantity;
  final String supplier;
  final String status; // 'Pending', 'Approved', 'Shipped', 'Received'
  final DateTime date;
  final String doctorId;

  const RequestEntity({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.supplier,
    required this.status,
    required this.date,
    required this.doctorId,
  });

  @override
  List<Object?> get props => [id, itemName, quantity, supplier, status, date, doctorId];
}
