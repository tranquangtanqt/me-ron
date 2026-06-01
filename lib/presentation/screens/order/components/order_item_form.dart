import '../../../../domain/entities/product_entity.dart';

class OrderItemForm {
  ProductEntity? product;
  int quantity;

  OrderItemForm({
    this.product,
    this.quantity = 1,
  });

  OrderItemForm copyWith({
    ProductEntity? product,
    int? quantity,
  }) {
    return OrderItemForm(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}