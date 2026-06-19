import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/utilities/console_logger.dart';
import '../../../data/models/order_item_model.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/order_item_usecases.dart';
import '../../../domain/usecases/order_usecases.dart';
import '../base/base_form_notifier.dart';
import '../../screens/order/components/order_item_form.dart';
import '../products/products_notifier.dart';
import 'order_form_state.dart';
import 'order_notifier.dart';

final orderFormNotifierProvider = NotifierProvider.autoDispose<OrderFormNotifier, OrderFormState>(
  OrderFormNotifier.new,
);

class OrderFormNotifier extends BaseFormNotifier<OrderFormState> {
  @override
  OrderFormState build() {
    return const OrderFormState();
  }

  Future<void> initOrderForm(int? orderId) async {
    final now = DateTime.now();
    final today = "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    if (orderId == null) {
      state = state.copyWith(
        deliveryDatetime: now,
        discountValue: 0,
        subTotal: 0,
        total: 0,
        isLoaded: true,
        status: OrderStatus.pending.value
      );
      return;
    }

    final orderRepository = ref.read(orderRepositoryProvider);
    var res = await GetOrderUsecase(orderRepository).call(orderId);

    final allProduct = ref.read(productsNotifierProvider).allProducts ?? [];

    if (res.isSuccess) {
      final orders = res.data;

      state = state.copyWith(
        userId: orders?[0].userId,
        status: orders?[0].status,
        deliveryDatetime: orders?[0].deliveryDatetime,
        discountValue: orders?[0].discountValue,
        subTotal: orders?[0].subTotal,
        total: orders?[0].total,
        note: orders?[0].note,
        isLoaded: true,
      );

      for (OrderModel order in orders ?? []) {
        final item = OrderItemForm(
            id: order.orderItemId,
            product: allProduct.firstWhere(
                  (p) => p.id == order.productId,
            ),
            quantity: order.quantity ?? 0
        );

        final current = state.items ?? [];
        state = state.copyWith(
          items: [...current, item],
        );
      }

     // state = state.copyWithGroup(order: res.data ?? [], isLoadingMore: false);
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createOrder() async {
    return performCreate(
      execute: () async {
        final orderRepository = ref.read(orderRepositoryProvider);

        final order = OrderEntity(
          id: null,
          userId: state.userId,
          status: state.status ?? OrderStatus.shipping.value,
          deliveryDatetime: state.deliveryDatetime,
          discountValue: state.discountValue ?? 0,
          subTotal: state.subTotal ?? 0,
          total: state.total ?? 0,
          note: state.note ?? '',
        );

        final res = await CreateOrderUsecase(orderRepository).call(order);

        final orderItemRepository = ref.read(orderItemRepositoryProvider);

        // var total = 0;
        for (final OrderItemForm item in state.items ?? []) {
          final oderItem = OrderItemEntity(
            orderId: res.data,
            productId: item.product?.id,
            snapshotName: item.product?.name,
            snapshotPrice: item.product?.price ?? 0,
            quantity: item.quantity,
            lineTotal: (item.product?.price ?? 0) * item.quantity,
          );

          await CreateOrderItemUsecase(orderItemRepository).call(oderItem);
          // total += oderItem.lineTotal;
        }

        // final updatedOrder = order.copyWith(
        //   id: res.data,
        //   total: total,
        // );
        //
        // await UpdateOrderUsecase(orderRepository).call(updatedOrder);

        return res;
      },
      onSuccess: () => ref.read(orderNotifierProvider.notifier).getAllOrder(true),
    );
  }

  Future<Result<void>> updatedOrder(int id) async {
    return performUpdate(
      execute: () async {
        final orderRepository = ref.read(orderRepositoryProvider);

        final order = OrderEntity(
          id: id,
          userId: state.userId,
          status: state.status ?? OrderStatus.shipping.value,
          deliveryDatetime: state.deliveryDatetime,
          discountValue: state.discountValue ?? 0,
          subTotal: state.subTotal ?? 0,
          total: state.total ?? 0,
          note: state.note ?? '',
        );

        final res = await UpdateOrderUsecase(orderRepository).call(order);

        final orderItemRepository = ref.read(orderItemRepositoryProvider);

        // var total = 0;
        for (final OrderItemForm item in state.items ?? []) {
          OrderItemEntity oderItem;
          if (item.id != null) {
            oderItem = OrderItemEntity(
              id: item.id,
              orderId: id,
              productId: item.product?.id,
              snapshotName: item.product?.name,
              snapshotPrice: item.product?.price ?? 0,
              quantity: item.quantity,
              lineTotal: (item.product?.price ?? 0) * item.quantity,
            );
            await UpdateOrderItemUsecase(orderItemRepository).call(oderItem);
          } else {
            oderItem = OrderItemEntity(
              orderId: id,
              productId: item.product?.id,
              snapshotName: item.product?.name,
              snapshotPrice: item.product?.price ?? 0,
              quantity: item.quantity,
              lineTotal: (item.product?.price ?? 0) * item.quantity,
            );
            await CreateOrderItemUsecase(orderItemRepository).call(oderItem);
          }

          // total += oderItem.lineTotal;
        }

        // final updatedOrder = order.copyWith(
        //   id: id,
        //   total: total,
        // );
        //
        // await UpdateOrderUsecase(orderRepository).call(updatedOrder);

        return res;
      },
      onSuccess: () => ref.read(orderNotifierProvider.notifier).getAllOrder(true),
    );
  }

  Future<Result<void>> deleteOrder(int id) async {
    return performDelete(
      execute: () async {
        final orderRepository = ref.read(orderRepositoryProvider);
        final res = await DeleteOrderUsecase(orderRepository).call(id);

        final orderItemRepository = ref.read(orderItemRepositoryProvider);

        for (final OrderItemForm item in state.items ?? []) {
          await DeleteOrderItemUsecase(orderItemRepository).call(item.id!);
        }

        return res;
      },
      onSuccess: () => ref.read(orderNotifierProvider.notifier).getAllOrder(true),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(orderNotifierProvider.notifier).getAllOrder(true);
  }

  void onChangedUser(int? value) {
    state = state.copyWith(userId: value);
  }

  void onChangedStatus(OrderStatus? value) {
    if (value == null) return;

    state = state.copyWith(status: value.value);
  }

  void onChangedDiscountValue(String value) {
    // state = state.copyWith(discountValue: int.tryParse(value));
    final discount = int.tryParse(value) ?? 0;

    final subTotal = state.subTotal ?? 0;

    state = state.copyWith(
      discountValue: discount,
      total: _calcTotal(subTotal, discount),
    );
  }

  void onChangedDeliveryDatetime(DateTime value) {
    state = state.copyWith(deliveryDatetime: value);
  }

  void removeItem(int index) {
    final currentItems = state.items ?? [];

    if (index < 0 || index >= currentItems.length) return;

    final updatedItems = [...currentItems]..removeAt(index);

    state = state.copyWith(
      items: updatedItems,
      subTotal: _calcSubTotal(updatedItems),
      total: _calcTotal(
        _calcSubTotal(updatedItems),
        state.discountValue ?? 0,
      ),
    );
  }

  void updateQuantity(int index, int qty) {
    final currentItems = state.items ?? [];

    if (index < 0 || index >= currentItems.length) return;

    final updatedItems = [...currentItems];

    final oldItem = updatedItems[index];

    updatedItems[index] = oldItem.copyWith(
      quantity: qty < 1 ? 1 : qty,
    );

    state = state.copyWith(
      items: updatedItems,
      subTotal: _calcSubTotal(updatedItems),
      total: _calcTotal(
        _calcSubTotal(updatedItems),
        state.discountValue ?? 0,
      ),
    );
  }

  void updateProduct(int index, ProductEntity? product) {
    final items = [...?state.items];
    items[index] = items[index].copyWith(product: product);

    state = state.copyWith(
      items: items,
      subTotal: _calcSubTotal(items),
      total: _calcTotal(
        _calcSubTotal(items),
        state.discountValue ?? 0,
      ),
    );
  }

  void onChangedNote(String value) {
    state = state.copyWith(note: value);
  }

  void addItem(ProductEntity? defaultProduct) {
    final items = [
      ...?state.items,
      OrderItemForm(
        product: defaultProduct,
        quantity: 1,
      ),
    ];

    final subTotal = _calcSubTotal(items);

    state = state.copyWith(
      items: items,
      subTotal: subTotal,
      total: _calcTotal(
        subTotal,
        state.discountValue ?? 0,
      ),
    );
  }

  int _calcSubTotal(List<OrderItemForm> items) {
    return items.fold<int>(
      0,
          (sum, item) =>
      sum + ((item.product?.price ?? 0) * item.quantity),
    );
  }

  int _calcTotal(int subTotal, int discountValue) {
    final result = subTotal - discountValue;
    return result < 0 ? 0 : result;
  }
}