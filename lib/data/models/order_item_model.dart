import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_item_entity.dart';

class OrderItemModel {
  int? id;
  int? orderId;
  int? productId;
  String? snapshotName;
  int? snapshotPrice;
  int quantity;
  int lineTotal;
  String? createdAt;
  String? updatedAt;

  OrderItemModel({
    this.id,
    this.orderId,
    this.productId,
    this.snapshotName,
    this.snapshotPrice,
    required this.quantity,
    required this.lineTotal,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'],
      orderId: json['orderId'],
      productId: json['productId'],
      snapshotName: json['snapshotName'],
      snapshotPrice: json['snapshotPrice'],
      quantity: json['quantity'] ?? '',
      lineTotal: json['lineTotal'] ?? '',
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'snapshotName': snapshotName,
      'snapshotPrice': snapshotPrice,
      'quantity': quantity,
      'lineTotal': lineTotal,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      productId: entity.productId,
      snapshotName: entity.snapshotName,
      snapshotPrice: entity.snapshotPrice,
      quantity: entity.quantity,
      lineTotal: entity.lineTotal,
      createdAt: entity.createdAt ?? DateTime.now().toIso8601String(),
      updatedAt: entity.updatedAt ?? DateTime.now().toIso8601String(),
    );
  }

  OrderItemEntity toEntity() {
    return OrderItemEntity(
      id: id,
      orderId: orderId,
      productId: productId ?? 0,
      snapshotName: snapshotName,
      snapshotPrice: snapshotPrice ?? 0,
      quantity: quantity ?? 0,
      lineTotal: lineTotal ?? 0,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'OrderItemModel('
        'orderId: $orderId, '
        'productId: $productId, '
        'snapshotName: $snapshotName, '
        'snapshotPrice: $snapshotPrice, '
        'quantity: $quantity, '
        'lineTotal: $lineTotal'
        ')';
  }
}
