int _parseIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class CustomerSummaryModel {
  final int userId;
  final String userName;
  final int orderCount;
  final int totalAmount;

  const CustomerSummaryModel({
    required this.userId,
    required this.userName,
    required this.orderCount,
    required this.totalAmount,
  });

  factory CustomerSummaryModel.fromJson(Map<String, dynamic> json) {
    return CustomerSummaryModel(
      userId: _parseIntValue(json['userId']),
      userName: json['userName']?.toString() ?? '',
      orderCount: _parseIntValue(json['cnt']),
      totalAmount: _parseIntValue(json['amt']),
    );
  }

  @override
  String toString() =>
      'CustomerSummaryModel(userId: $userId, userName: $userName, orderCount: $orderCount, totalAmount: $totalAmount)';
}
