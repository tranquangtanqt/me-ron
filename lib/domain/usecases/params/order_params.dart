import 'base_params.dart';

class OrderParams<T> extends BaseParams<void> {
  final BaseParams base;
  final String? contains;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? status;
  final int? userId;

  const OrderParams({
    required this.base,
    this.contains,
    this.fromDate,
    this.toDate,
    this.status,
    this.userId,
  });
}
