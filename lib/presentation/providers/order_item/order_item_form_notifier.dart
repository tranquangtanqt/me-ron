import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/usecases/order_item_usecases.dart';
import '../base/base_form_notifier.dart';
import 'order_item_form_state.dart';
import 'order_item_notifier.dart';

final orderItemFormNotifierProvider = NotifierProvider.autoDispose<OrderItemFormNotifier, OrderItemFormState>(
  OrderItemFormNotifier.new,
);

class OrderItemFormNotifier extends BaseFormNotifier<OrderItemFormState> {
  @override
  OrderItemFormState build() {
    return const OrderItemFormState();
  }

  Future<void> initOrderItemForm(int? orderItemId) async {
    if (orderItemId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final orderItemRepository = ref.read(orderItemRepositoryProvider);
    var res = await GetOrderItemUsecase(orderItemRepository).call(orderItemId);

    if (res.isSuccess) {
      var orderItem = res.data;

      state = state.copyWith(
        orderId: orderItem?.orderId,
        productId: orderItem?.productId,
        snapshotName: orderItem?.snapshotName,
        snapshotPrice: orderItem?.snapshotPrice,
        quantity: orderItem?.quantity,
        lineTotal: orderItem?.lineTotal,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createOrderItem() async {
    return performCreate(
      execute: () async {
        final orderItemRepository = ref.read(orderItemRepositoryProvider);
        final orderItem = OrderItemEntity(
          orderId: state.orderId,
          productId: state.productId,
          snapshotName: state.snapshotName ?? '',
          snapshotPrice: state.snapshotPrice ?? 0,
          quantity: state.quantity ?? 0,
          lineTotal: state.lineTotal ?? 0,
        );
        return await CreateOrderItemUsecase(orderItemRepository).call(
            orderItem);
      },
      onSuccess: () =>
          ref.read(orderItemNotifierProvider.notifier).getAllOrderItem(),
    );
  }

  Future<Result<void>> updatedOrderItem(int id) async {
    return performUpdate(
      execute: () async {
        final orderItemRepository = ref.read(orderItemRepositoryProvider);
        final orderItem = OrderItemEntity(
          id: id,
          orderId: state.orderId,
          productId: state.productId,
          snapshotName: state.snapshotName ?? '',
          snapshotPrice: state.snapshotPrice ?? 0,
          quantity: state.quantity ?? 0,
          lineTotal: state.lineTotal ?? 0,
        );
        return await UpdateOrderItemUsecase(orderItemRepository).call(
            orderItem);
      },
      onSuccess: () =>
          ref.read(orderItemNotifierProvider.notifier).getAllOrderItem(),
    );
  }

  Future<Result<void>> deleteOrderItem(int id) async {
    return performDelete(
      execute: () async {
        final orderItemRepository = ref.read(orderItemRepositoryProvider);
        return await DeleteOrderItemUsecase(orderItemRepository).call(id);
      },
      onSuccess: () =>
          ref.read(orderItemNotifierProvider.notifier).getAllOrderItem(),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(orderItemNotifierProvider.notifier).getAllOrderItem();
  }
}