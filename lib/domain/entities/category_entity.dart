import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final int? id;
  final String? name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const CategoryEntity({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  CategoryEntity copyWith({
    String? code,
    String? name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      description: description ?? this.description,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    createdAt,
    updatedAt,
  ];
}