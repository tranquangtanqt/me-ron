class ProductSummaryModel {
  int? productId;
  String productName;
  int quantity;

  ProductSummaryModel({
    this.productId,
    required this.productName,
    required this.quantity,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
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
      'ProductSummary(productId: $productId, productName: $productName, quantity: $quantity)';
}
