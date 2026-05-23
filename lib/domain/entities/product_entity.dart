import 'package:equatable/equatable.dart';

class ProductEntity extends Equatable {
  final int? id;
  final int? categoryId;
  final String name;
  final String? imageUrl;
  final int price;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const ProductEntity({
    this.id,
    this.categoryId,
    required this.name,
    this.imageUrl,
    required this.price,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  ProductEntity copyWith({
    int? id,
    int? categoryId,
    String? name,
    String? imageUrl,
    int? price,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      price: price ?? this.price,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    categoryId,
    name,
    imageUrl,
    price,
    description,
    createdAt,
    updatedAt,
  ];
}
