import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final int? id;
  final int? orderId;
  final int? productId;
  final String? snapshotName;
  final int snapshotPrice;
  final int quantity;
  final int lineTotal;
  final String? createdAt;
  final String? updatedAt;

  const OrderItemEntity({
    this.id,
    this.orderId,
    this.productId,
    this.snapshotName,
    required this.snapshotPrice,
    required this.quantity,
    required this.lineTotal,
    this.createdAt,
    this.updatedAt,
  });

  OrderItemEntity copyWith({
    final int? id,
    final int? orderId,
    final int? productId,
    final String? snapshotName,
    final int? snapshotPrice,
    final int? quantity,
    final int? lineTotal,
    final String? createdAt,
    final String? updatedAt,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      snapshotName: snapshotName ?? this.snapshotName,
      snapshotPrice: snapshotPrice ?? this.snapshotPrice,
      quantity: quantity ?? this.quantity,
      lineTotal: lineTotal ?? this.lineTotal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productId,
    snapshotName,
    snapshotPrice,
    quantity,
    lineTotal,
    createdAt,
    updatedAt,
  ];
}
