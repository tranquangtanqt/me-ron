import 'base_params.dart';

class ReportOrderParams<T> extends BaseParams<void> {
  final BaseParams base;
  final String? contains;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? status;
  final int? userId;

  const ReportOrderParams({
    required this.base,
    this.contains,
    this.fromDate,
    this.toDate,
    this.status,
    this.userId,
  });
}
