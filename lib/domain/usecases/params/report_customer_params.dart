import 'base_params.dart';

class ReportCustomerParams<T> extends BaseParams<void> {
  final BaseParams base;
  final DateTime? fromDate;
  final DateTime? toDate;

  const ReportCustomerParams({
    required this.base,
    this.fromDate,
    this.toDate,
  });
}
