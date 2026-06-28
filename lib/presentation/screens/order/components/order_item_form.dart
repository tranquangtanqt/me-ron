import '../../../../domain/entities/product_entity.dart';

class OrderItemForm {
  int? id;
  ProductEntity? product;
  int quantity;
  int? snapshotPrice;
  int? originalProductId;

  OrderItemForm({
    this.id,
    this.product,
    this.quantity = 1,
    this.snapshotPrice,
    this.originalProductId,
  });

  OrderItemForm copyWith({
    int? id,
    ProductEntity? product,
    int? quantity,
    int? snapshotPrice,
    int? originalProductId,
  }) {
    return OrderItemForm(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      snapshotPrice: snapshotPrice ?? this.snapshotPrice,
      originalProductId: originalProductId ?? this.originalProductId,
    );
  }
}