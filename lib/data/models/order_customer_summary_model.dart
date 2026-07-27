int _parseIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class OrderCustomerSummaryModel {
  final int userId;
  final String userName;
  final int orderCount;
  final int totalAmount;

  const OrderCustomerSummaryModel({
    required this.userId,
    required this.userName,
    required this.orderCount,
    required this.totalAmount,
  });

  factory OrderCustomerSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderCustomerSummaryModel(
      userId: _parseIntValue(json['userId']),
      userName: json['userName']?.toString() ?? '',
      orderCount: _parseIntValue(json['orderCount']),
      totalAmount: _parseIntValue(json['totalAmount']),
    );
  }

  @override
  String toString() =>
      'OrderCustomerSummaryModel(userId: $userId, userName: $userName, orderCount: $orderCount, totalAmount: $totalAmount)';
}
