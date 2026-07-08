import '../../domain/entities/purchase_item_entity.dart';

class PurchaseItemModel {
  int? id;
  int? purchaseId;
  String? name;
  int? price;
  String? createdAt;
  String? updatedAt;

  PurchaseItemModel({
    this.id,
    this.purchaseId,
    this.name,
    this.price,
    this.createdAt,
    this.updatedAt,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value, {int fallback = 0}) {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value) ?? fallback;
      return fallback;
    }

    return PurchaseItemModel(
      id: json['id'],
      purchaseId: json['purchaseId'],
      name: json['name']?.toString(),
      price: parseInt(json['price']),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'purchaseId': purchaseId,
      'name': name,
      'price': price,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory PurchaseItemModel.fromEntity(PurchaseItemEntity entity) {
    return PurchaseItemModel(
      id: entity.id,
      purchaseId: entity.purchaseId,
      name: entity.name,
      price: entity.price,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  PurchaseItemEntity toEntity() {
    return PurchaseItemEntity(
      id: id,
      purchaseId: purchaseId,
      name: name,
      price: price ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'PurchaseItemModel('
        'purchaseId: $purchaseId, '
        'name: $name, '
        'price: $price, '
        ')';
  }
}
