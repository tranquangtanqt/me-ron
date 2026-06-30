import '../../domain/entities/product_entity.dart';

class ProductModel {
  int? id;
  int? categoryId;
  String name;
  String? imageUrl;
  int price;
  String? description;
  String? createdAt;
  String? updatedAt;

  ProductModel({
    this.id,
    this.categoryId,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      categoryId: json['categoryId'] == null || json['categoryId'] == ''
          ? null
          : int.tryParse(json['categoryId'].toString()),
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      price: json['price'] ?? 0,
      description: json['description'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'description': description,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory ProductModel.fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      categoryId: entity.categoryId,
      name: entity.name,
      imageUrl: entity.imageUrl,
      price: entity.price,
      description: entity.description,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      categoryId: categoryId,
      name: name ?? '',
      imageUrl: imageUrl ?? '',
      price: price ?? 0,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
