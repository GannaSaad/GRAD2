import '../../domain/entities/supplier_entity.dart';

class SupplierModel {
  final String id;
  final String name;
  final String companyId;
  final String email;
  final String phone;
  final String address;

  SupplierModel({
    required this.id,
    required this.name,
    required this.companyId,
    required this.email,
    required this.phone,
    required this.address,
  });

  factory SupplierModel.fromFirestore(Map<String, dynamic> json, String id) {
    return SupplierModel(
      id: id,
      name: json['name'] ?? '',
      companyId: json['companyId'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'companyId': companyId,
      'email': email,
      'phone': phone,
      'address': address,
    };
  }

  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id,
      name: name,
      companyId: companyId,
      email: email,
      phone: phone,
      address: address,
    );
  }
}
