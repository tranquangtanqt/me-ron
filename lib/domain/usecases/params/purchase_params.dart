import 'base_params.dart';

class PurchaseParams<T> extends BaseParams<void> {
  final BaseParams base;
  final String? contains;
  final DateTime? fromDate;
  final DateTime? toDate;

  const PurchaseParams({
    required this.base,
    this.contains,
    this.fromDate,
    this.toDate,
  });
}
