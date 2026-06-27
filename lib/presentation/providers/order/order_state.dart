import '../../../data/models/order_item_model.dart';
import '../../../data/models/order_model.dart';

class OrderState {
  final List<OrderModel>? allOrder;
  // final bool isLoadingMore;
  final String? error;

  const OrderState({
    this.allOrder,
    // this.isLoadingMore = false,
    this.error
  });

  OrderState copyWith({
    List<OrderModel>? allOrder,
    // bool? isLoadingMore,
    String? error
  }) {
    return OrderState(
      allOrder: allOrder ?? this.allOrder,
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }

  OrderState copyWithGroup({
    List<OrderModel>? allOrder,
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

    return OrderState(
      allOrder: map.values.toList(),
      // isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
