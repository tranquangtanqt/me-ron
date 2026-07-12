int _parseIntValue(dynamic value, {int fallback = 0}) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? fallback;
  return fallback;
}

class OrderStatusSummaryModel {
  final int status;
  final int count;
  final int totalAmount;

  const OrderStatusSummaryModel({
    required this.status,
    required this.count,
    required this.totalAmount,
  });

  factory OrderStatusSummaryModel.fromJson(Map<String, dynamic> json) {
    return OrderStatusSummaryModel(
      status: _parseIntValue(json['status']),
      count: _parseIntValue(json['cnt']),
      totalAmount: _parseIntValue(json['amt']),
    );
  }

  @override
  String toString() => 'OrderStatusSummaryModel(status: $status, count: $count, totalAmount: $totalAmount)';
}
