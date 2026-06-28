class OrderSummaryModel {
  int? productId;
  String productName;
  int quantity;

  OrderSummaryModel({
    this.productId,
    required this.productName,
    required this.quantity,
  });

  factory OrderSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderSummaryModel(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
    };
  }

  @override
  String toString() =>
      'OrderSummary(productId: $productId, productName: $productName, quantity: $quantity)';
}
