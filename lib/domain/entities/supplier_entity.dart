import 'package:equatable/equatable.dart';

class SupplierEntity extends Equatable {
  final String id;
  final String name;
  final String companyId;
  final String email;
  final String phone;
  final String address;

  const SupplierEntity({
    required this.id,
    required this.name,
    required this.companyId,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  List<Object?> get props => [id, name, companyId, email, phone, address];
}
