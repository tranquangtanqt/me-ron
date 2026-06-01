import 'dart:io';

import '../../../data/models/order_model.dart';
import '../../screens/order/components/order_item_form.dart';

class OrderFormState {
  final int? userId;
  final int? status;
  final String? deliveryDatetime;
  final int? discountValue;
  final int? subTotal;
  final int? total;
  final String? note;
  final bool isLoaded;
  final List<OrderItemForm>? items;

  const OrderFormState({
    this.userId,
    this.status,
    this.deliveryDatetime,
    this.discountValue,
    this.subTotal,
    this.total,
    this.note,
    this.isLoaded = false,
    this.items,
  });

  OrderFormState copyWith({
    int? userId,
    int? status,
    String? deliveryDatetime,
    int? discountValue,
    int? subTotal,
    int? total,
    String? note,
    bool? isLoaded,
    List<OrderItemForm>? items,
  }) {
    return OrderFormState(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      deliveryDatetime: deliveryDatetime ?? this.deliveryDatetime,
      discountValue: discountValue ?? this.discountValue,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      note: note ?? this.note,
      isLoaded: isLoaded ?? this.isLoaded,
      items: items ?? this.items,
    );
  }

  OrderFormState copyWithGroup({
    OrderModel? order,
    bool? isLoadingMore,
    String? error
  }) {
    final Map<int, OrderModel> map = {};
    if (order != null) {
      if (order.orderId != null) {
        // order.items?.add(
        //   OrderItemForm(
        //     orderId: row.orderId,
        //     productId: row.productId,
        //     snapshotName: row.snapshotName,
        //     snapshotPrice: row.snapshotPrice,
        //     quantity: row.quantity ?? 0,
        //     lineTotal: row.lineTotal ?? 0,
        //   ),
        // );
      }
    }

    return OrderFormState(
      userId: userId ?? this.userId,
      status: status ?? this.status,
      deliveryDatetime: deliveryDatetime ?? this.deliveryDatetime,
      discountValue: discountValue ?? this.discountValue,
      subTotal: subTotal ?? this.subTotal,
      total: total ?? this.total,
      note: note ?? this.note,
      isLoaded: isLoaded ?? this.isLoaded,
      items: items ?? this.items,
    );
  }
}
