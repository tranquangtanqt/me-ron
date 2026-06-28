import 'base_params.dart';

class ReportProductParams<T> extends BaseParams<void> {
  final BaseParams base;
  final String? contains;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? productId;

  const ReportProductParams({
    required this.base,
    this.contains,
    this.fromDate,
    this.toDate,
    this.productId,
  });
}
