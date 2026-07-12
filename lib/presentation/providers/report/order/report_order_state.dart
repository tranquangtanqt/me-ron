import '../../../../data/models/order_item_model.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/order_status_summary_model.dart';
import '../../../../data/models/product_summary_model.dart';

class ReportOrderState {
  final List<OrderModel>? allOrder;
  final int? total;
  final Map<int, ProductSummaryModel>? productSummary;
  final Map<int, OrderStatusSummaryModel>? orderStatusSummary;
  final String? error;

  const ReportOrderState({
    this.allOrder,
    this.total,
    this.productSummary,
    this.orderStatusSummary,
    this.error,
  });

  ReportOrderState copyWith({
    List<OrderModel>? allOrder,
    int? total,
    Map<int, ProductSummaryModel>? productSummary,
    Map<int, OrderStatusSummaryModel>? orderStatusSummary,
    String? error,
  }) {
    return ReportOrderState(
      allOrder: allOrder ?? this.allOrder,
      total: total ?? this.total,
      productSummary: productSummary ?? this.productSummary,
      orderStatusSummary: orderStatusSummary ?? this.orderStatusSummary,
      error: error ?? this.error,
    );
  }

  static List<OrderModel> _group(List<OrderModel> rows) {
    final Map<int, OrderModel> map = {};

    for (final row in rows) {
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

    return map.values.toList();
  }

  ReportOrderState copyWithGroup({
    required List<OrderModel> newRows,
    required bool append,
    int? total,
    Map<int, ProductSummaryModel>? productSummary,
    Map<int, OrderStatusSummaryModel>? orderStatusSummary,
    String? error,
  }) {
    final grouped = _group(newRows);

    return ReportOrderState(
      allOrder: append ? [...?allOrder, ...grouped] : grouped,
      total: total ?? this.total,
      productSummary: productSummary ?? this.productSummary,
      orderStatusSummary: orderStatusSummary ?? this.orderStatusSummary,
      error: error ?? this.error,
    );
  }
}
