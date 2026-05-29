import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user_entity.dart';

class UserModel {
  int? id;
  String? name;
  String? address;
  String? phone;
  String? note;
  String? createdAt;
  String? updatedAt;

  UserModel({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      note: json['note'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'note': note,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      address: entity.address,
      phone: entity.phone,
      note: entity.note,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      address: address,
      phone: phone,
      note: note,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert Firebase User to UserModel
  // factory UserModel.fromFirebaseUser(
  //   firebase_auth.User firebaseUser, {
  //   AuthProvider authProvider = AuthProvider.google,
  // }) {
  //   return UserModel(
  //     id: firebaseUser.uid,
  //     email: firebaseUser.email,
  //     phone: firebaseUser.phoneNumber,
  //     name: firebaseUser.displayName,
  //     note: null,
  //     birthdate: null,
  //     imageUrl: firebaseUser.photoURL,
  //     authProvider: authProvider.value,
  //     createdAt: null,
  //     updatedAt: null,
  //   );
  // }
}
