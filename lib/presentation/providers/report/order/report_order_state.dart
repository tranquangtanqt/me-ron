import '../../../../data/models/order_item_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/order_summary_model.dart';
import '../../../../data/models/product_summary_model.dart';

class ReportOrderState {
  final List<OrderModel>? allOrder;
  final Map<int, ProductSummaryModel>? productSummary;
  final Map<int, OrderSummaryModel>? orderSummary;
  // final bool isLoadingMore;
  final String? error;

  const ReportOrderState({
    this.allOrder,
    this.productSummary,
    this.orderSummary,
    // this.isLoadingMore = false,
    this.error
  });

  ReportOrderState copyWith({
    List<OrderModel>? allOrder,
    Map<int, ProductSummaryModel>? productSummary,
    Map<int, OrderSummaryModel>? orderSummary,
    // bool? isLoadingMore,
    String? error
  }) {
    return ReportOrderState(
      allOrder: allOrder ?? this.allOrder,
      productSummary: productSummary ?? this.productSummary,
      orderSummary: orderSummary ?? this.orderSummary,
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  ReportOrderState copyWithGroup({
    List<OrderModel>? allOrder,
    Map<int, ProductSummaryModel>? productSummary,
    Map<int, OrderSummaryModel>? orderSummary,
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

    return ReportOrderState(
      allOrder: map.values.toList(),
      productSummary: productSummary,
      orderSummary: orderSummary,
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
