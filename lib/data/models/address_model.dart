import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/address_entity.dart';

class AddressModel {
  String code;
  String? name;
  String? createdAt;
  String? updatedAt;

  AddressModel({
    required this.code,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      code: json['code'],
      name: json['name'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      code: entity.code,
      name: entity.name,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  AddressEntity toEntity() {
    return AddressEntity(
      code: code,
      name: name,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
