import '../../domain/entities/category_entity.dart';

class CategoryModel {
  int? id;
  String? name;
  String? description;
  String? createdAt;
  String? updatedAt;

  CategoryModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
