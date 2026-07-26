class ProductSummaryModel {
  int? productId;
  String productName;
  int quantity;
  num totalAmount;

  ProductSummaryModel({
    this.productId,
    required this.productName,
    required this.quantity,
    this.totalAmount = 0,
  });

  factory ProductSummaryModel.fromJson(Map<String, dynamic> json) {
    return ProductSummaryModel(
      productId: json['productId'],
      productName: json['productName'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'totalAmount': totalAmount,
    };
  }

  @override
  String toString() =>
      'ProductSummary(productId: $productId, productName: $productName, quantity: $quantity, totalAmount: $totalAmount)';
}
