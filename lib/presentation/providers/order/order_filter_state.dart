import '../../../data/models/order_item_model.dart';
import '../../../data/models/order_model.dart';

class OrderFilterState {
  final int? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? userId;

  const OrderFilterState({
    required this.status,
    required this.fromDate,
    required this.toDate,
    this.userId,
  });

  OrderFilterState copyWith({
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
    int? userId,
  }) {
    return OrderFilterState(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      userId: userId ?? this.userId,
    );
  }
}