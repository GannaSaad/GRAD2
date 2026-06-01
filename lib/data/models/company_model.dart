import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/company_entity.dart';

class CompanyModel {
  final String id;
  final String name;
  final String? description;

  CompanyModel({
    required this.id,
    required this.name,
    this.description,
  });

  factory CompanyModel.fromFirestore(Map<String, dynamic> json, String id) {
    return CompanyModel(
      id: id,
      name: json['name'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
    };
  }

  CompanyEntity toEntity() {
    return CompanyEntity(
      id: id,
      name: name,
      description: description,
    );
  }

  factory CompanyModel.fromEntity(CompanyEntity entity) {
    return CompanyModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
    );
  }
}
