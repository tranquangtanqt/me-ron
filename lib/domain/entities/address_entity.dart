import 'package:equatable/equatable.dart';

class AddressEntity extends Equatable {
  final String code;
  final String? name;
  final String? createdAt;
  final String? updatedAt;

  const AddressEntity({
    required this.code,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  AddressEntity copyWith({
    String? code,
    String? name,
    String? createdAt,
    String? updatedAt,
  }) {
    return AddressEntity(
      code: code ?? this.code,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    code,
    name,
    createdAt,
    updatedAt,
  ];
}