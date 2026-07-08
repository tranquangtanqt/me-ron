import 'package:equatable/equatable.dart';

class PurchaseItemEntity extends Equatable {
  final int? id;
  final int? purchaseId;
  final String? name;
  final int price;
  final String? createdAt;
  final String? updatedAt;

  const PurchaseItemEntity({
    this.id,
    this.purchaseId,
    this.name,
    required this.price,
    this.createdAt,
    this.updatedAt,
  });

  PurchaseItemEntity copyWith({
    final int? id,
    final int? purchaseId,
    final int? productId,
    final String? name,
    final int? price,
    final String? createdAt,
    final String? updatedAt,
  }) {
    return PurchaseItemEntity(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      name: name ?? this.name,
      price: price ?? this.price,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    purchaseId,
    name,
    price,
    createdAt,
    updatedAt,
  ];
}
