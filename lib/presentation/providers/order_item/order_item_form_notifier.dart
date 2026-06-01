import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/usecases/order_item_usecases.dart';
import 'order_item_form_state.dart';
import 'order_item_notifier.dart';

final orderItemFormNotifierProvider = NotifierProvider.autoDispose<OrderItemFormNotifier, OrderItemFormState>(
  OrderItemFormNotifier.new,
);

class OrderItemFormNotifier extends AutoDisposeNotifier<OrderItemFormState> {
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
    try {
      // final storageRepository = ref.read(storageRepositoryProvider);
      final orderItemRepository = ref.read(orderItemRepositoryProvider);

      var orderItem = OrderItemEntity(
        orderId: state.orderId,
        productId: state.productId,
        snapshotName: state.snapshotName ?? '',
        snapshotPrice: state.snapshotPrice ?? 0,
        quantity: state.quantity ?? 0,
        lineTotal: state.lineTotal ?? 0,
      );

      var res = await CreateOrderItemUsecase(orderItemRepository).call(orderItem);

      // Refresh orders
      ref.read(orderItemNotifierProvider.notifier).getAllOrderItem();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> updatedOrderItem(int id) async {
    try {
      // final storageRepository = ref.read(storageRepositoryProvider);
      final orderItemRepository = ref.read(orderItemRepositoryProvider);

      // if (state.imageFile != null) {
      //   final res = await UploadOrderImageUsecase(storageRepository).call(state.imageFile!.path);
      //   userId = res.data;
      // }

      var orderItem = OrderItemEntity(
        id: id,
        orderId: state.orderId,
        productId: state.productId,
        snapshotName: state.snapshotName ?? '',
        snapshotPrice: state.snapshotPrice ?? 0,
        quantity: state.quantity ?? 0,
        lineTotal: state.lineTotal ?? 0,
      );

      var res = await UpdateOrderItemUsecase(orderItemRepository).call(orderItem);

      // Refresh orders
      ref.read(orderItemNotifierProvider.notifier).getAllOrderItem();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> deleteOrderItem(int id) async {
    try {
      final orderItemRepository = ref.read(orderItemRepositoryProvider);
      var res = await DeleteOrderItemUsecase(orderItemRepository).call(id);

      // Refresh orders
      ref.read(orderItemNotifierProvider.notifier).getAllOrderItem();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  // void onChangedCategory(int? value) {
  //   state = state.copyWith(status: value);
  // }
  //
  // void onChangedName(String value) {
  //   state = state.copyWith(deliveryDatetime: value);
  // }
  //
  // void onChangedPrice(String value) {
  //   state = state.copyWith(discountValue: int.tryParse(value));
  // }
  //
  // void onChangedDesc(String value) {
  //   state = state.copyWith(note: value);
  // }
}