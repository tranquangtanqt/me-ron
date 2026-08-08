import '../../../../domain/entities/product_entity.dart';

class OrderItemForm {
  // Stable per-row identity, used as a widget key so text-editing rows
  // (free items) keep their focus/cursor across rebuilds instead of
  // getting mixed up with a neighboring row when the list is reordered.
  final Object localKey;
  int? id;
  ProductEntity? product;
  int quantity;
  int? snapshotPrice;
  int? originalProductId;
  bool isFreeItem;
  String? freeItemName;
  int? freeItemPrice;

  OrderItemForm({
    Object? localKey,
    this.id,
    this.product,
    this.quantity = 1,
    this.snapshotPrice,
    this.originalProductId,
    this.isFreeItem = false,
    this.freeItemName,
    this.freeItemPrice,
  }) : localKey = localKey ?? Object();

  OrderItemForm copyWith({
    int? id,
    ProductEntity? product,
    int? quantity,
    int? snapshotPrice,
    int? originalProductId,
    bool? isFreeItem,
    String? freeItemName,
    int? freeItemPrice,
  }) {
    return OrderItemForm(
      localKey: localKey,
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      snapshotPrice: snapshotPrice ?? this.snapshotPrice,
      originalProductId: originalProductId ?? this.originalProductId,
      isFreeItem: isFreeItem ?? this.isFreeItem,
      freeItemName: freeItemName ?? this.freeItemName,
      freeItemPrice: freeItemPrice ?? this.freeItemPrice,
    );
  }
}
