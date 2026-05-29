import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final int? id;
  final String? name;
  final String? address;
  final String? phone;
  final String? note;
  final String? createdAt;
  final String? updatedAt;

  const UserEntity({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.note,
    this.createdAt,
    this.updatedAt,
  });

  UserEntity copyWith({
    int? id,
    String? name,
    String? address,
    String? phone,
    String? note,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    address,
    phone,
    note,
    createdAt,
    updatedAt,
  ];
}

enum AuthProvider {
  google('google');
  // add other if needed

  final String value;
  const AuthProvider(this.value);

  static AuthProvider? fromValue(String? value) {
    return AuthProvider.values.where((e) => e.value == value).firstOrNull;
  }
}
