import '../../../../data/models/order_item_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/product_summary_model.dart';

class ReportProductState {
  final List<OrderModel>? allOrder;
  final Map<int, ProductSummaryModel>? productSummary;
  // final bool isLoadingMore;
  final String? error;

  const ReportProductState({
    this.allOrder,
    this.productSummary,
    // this.isLoadingMore = false,
    this.error
  });

  ReportProductState copyWith({
    List<OrderModel>? allOrder,
    Map<int, ProductSummaryModel>? productSummary,
    // bool? isLoadingMore,
    String? error
  }) {
    return ReportProductState(
      allOrder: allOrder ?? this.allOrder,
      productSummary: productSummary ?? this.productSummary,
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  ReportProductState copyWithGroup({
    List<OrderModel>? allOrder,
    Map<int, ProductSummaryModel>? productSummary,
    bool? isLoadingMore,
    String? error,
  }) {
    final Map<int, OrderModel> map = {};

    final source = allOrder ?? [];

    for (final row in source) {
      final orderId = row.id!;

      map.putIfAbsent(
        orderId,
            () => OrderModel(
          id: row.id,
          userId: row.userId,
          userName: row.userName,
          status: row.status,
          deliveryDatetime: row.deliveryDatetime,
          paymentDatetime: row.paymentDatetime,
          discountValue: row.discountValue,
          subTotal: row.subTotal,
          total: row.total,
          note: row.note,
          createdAt: row.createdAt,
          updatedAt: row.updatedAt,
          items: <OrderItemModel>[],
        ),
      );

      if (row.orderItemId != null) {
        map[orderId]!.items = [
          ...?map[orderId]!.items,
          OrderItemModel(
            id: row.orderItemId,
            orderId: row.orderId,
            productId: row.productId,
            snapshotName: row.snapshotName,
            snapshotPrice: row.snapshotPrice,
            quantity: row.quantity ?? 0,
            lineTotal: row.lineTotal ?? 0,
          ),
        ];
      }
    }

    return ReportProductState(
      allOrder: map.values.toList(),
      productSummary: productSummary,
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
