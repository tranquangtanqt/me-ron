import '../../../../domain/entities/product_entity.dart';

class OrderItemForm {
  int? id;
  ProductEntity? product;
  int quantity;

  OrderItemForm({
    this.id,
    this.product,
    this.quantity = 1,
  });

  OrderItemForm copyWith({
    int? id,
    ProductEntity? product,
    int? quantity,
  }) {
    return OrderItemForm(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}