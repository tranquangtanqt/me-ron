import '../../../../data/models/order_model.dart';
import '../../../../data/models/product_summary_model.dart';
import '../../../../data/models/purchase_item_summary_model.dart';
import '../../../../data/models/purchase_model.dart';

class ReportSummaryState {
  final List<OrderModel>? allOrder;
  final Map<int, ProductSummaryModel>? productSummary;
  final List<PurchaseModel>? allPurchase;
  final Map<String, PurchaseItemSummaryModel>? purchaseItemSummary;
  final String? error;

  const ReportSummaryState({
    this.allOrder,
    this.productSummary,
    this.allPurchase,
    this.purchaseItemSummary,
    this.error,
  });

  ReportSummaryState copyWith({
    List<OrderModel>? allOrder,
    Map<int, ProductSummaryModel>? productSummary,
    List<PurchaseModel>? allPurchase,
    Map<String, PurchaseItemSummaryModel>? purchaseItemSummary,
    String? error,
  }) {
    return ReportSummaryState(
      allOrder: allOrder ?? this.allOrder,
      productSummary: productSummary ?? this.productSummary,
      allPurchase: allPurchase ?? this.allPurchase,
      purchaseItemSummary: purchaseItemSummary ?? this.purchaseItemSummary,
      error: error ?? this.error,
    );
  }
}
