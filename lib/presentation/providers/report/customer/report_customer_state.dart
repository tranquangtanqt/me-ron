import '../../../../data/models/customer_summary_model.dart';

class ReportCustomerState {
  final List<CustomerSummaryModel>? customers;
  final String? error;

  const ReportCustomerState({
    this.customers,
    this.error,
  });

  ReportCustomerState copyWith({
    List<CustomerSummaryModel>? customers,
    String? error,
  }) {
    return ReportCustomerState(
      customers: customers ?? this.customers,
      error: error ?? this.error,
    );
  }
}
