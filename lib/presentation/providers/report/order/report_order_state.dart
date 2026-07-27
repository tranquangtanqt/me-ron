import '../../../../data/models/order_customer_summary_model.dart';
import '../../../../data/models/order_status_summary_model.dart';
import '../../../../data/models/product_summary_model.dart';

class ReportOrderState {
  final List<OrderCustomerSummaryModel>? customerSummary;
  final int? total;
  final Map<int, ProductSummaryModel>? productSummary;
  final Map<int, OrderStatusSummaryModel>? orderStatusSummary;
  final String? error;

  const ReportOrderState({
    this.customerSummary,
    this.total,
    this.productSummary,
    this.orderStatusSummary,
    this.error,
  });

  ReportOrderState copyWith({
    List<OrderCustomerSummaryModel>? customerSummary,
    int? total,
    Map<int, ProductSummaryModel>? productSummary,
    Map<int, OrderStatusSummaryModel>? orderStatusSummary,
    String? error,
  }) {
    return ReportOrderState(
      customerSummary: customerSummary ?? this.customerSummary,
      total: total ?? this.total,
      productSummary: productSummary ?? this.productSummary,
      orderStatusSummary: orderStatusSummary ?? this.orderStatusSummary,
      error: error ?? this.error,
    );
  }
}
