import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/utilities/console_logger.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecases/order_usecases.dart';
// import '../../../domain/usecases/storage_usecases.dart';
import '../../screens/order/components/order_item_form.dart';
import 'order_form_state.dart';
import 'order_notifier.dart';

final orderFormNotifierProvider = NotifierProvider.autoDispose<OrderFormNotifier, OrderFormState>(
  OrderFormNotifier.new,
);

class OrderFormNotifier extends AutoDisposeNotifier<OrderFormState> {
  @override
  OrderFormState build() {
    return const OrderFormState();
  }

  Future<void> initOrderForm(int? orderId) async {
    if (orderId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final orderRepository = ref.read(orderRepositoryProvider);
    var res = await GetOrderUsecase(orderRepository).call(orderId);

    if (res.isSuccess) {
      var order = res.data;

      // state = state.copyWith(
      //   userId: order?.userId,
      //   status: order?.status,
      //   deliveryDatetime: order?.deliveryDatetime,
      //   discountValue: order?.discountValue,
      //   subTotal: order?.subTotal,
      //   total: order?.total,
      //   note: order?.note,
      //   isLoaded: true,
      // );
     // state = state.copyWithGroup(order: res.data ?? [], isLoadingMore: false);
      print(state);
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createOrder() async {
    try {
      // final storageRepository = ref.read(storageRepositoryProvider);
      final orderRepository = ref.read(orderRepositoryProvider);

      var order = OrderEntity(
        userId: state.userId,
        status: state.status ?? OrderStatus.shipping.value,
        deliveryDatetime: state.deliveryDatetime ?? '',
        discountValue: state.discountValue ?? 0,
        subTotal: state.subTotal ?? 0,
        total: state.total ?? 0,
        note: state.note ?? '',
      );

      var res = await CreateOrderUsecase(orderRepository).call(order);

      // Refresh orders
      ref.read(orderNotifierProvider.notifier).getAllOrder();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> updatedOrder(int id) async {
    try {
      // final storageRepository = ref.read(storageRepositoryProvider);
      final orderRepository = ref.read(orderRepositoryProvider);

      var userId = state.userId;

      // if (state.imageFile != null) {
      //   final res = await UploadOrderImageUsecase(storageRepository).call(state.imageFile!.path);
      //   userId = res.data;
      // }

      cl('userId $userId');

      var order = OrderEntity(
        id: id,
        userId: state.userId,
        status: state.status ?? OrderStatus.shipping.value,
        deliveryDatetime: state.deliveryDatetime!,
        discountValue: state.discountValue ?? 0,
        subTotal: state.subTotal ?? 0,
        total: state.total ?? 0,
        note: state.note ?? '',
      );

      var res = await UpdateOrderUsecase(orderRepository).call(order);

      // Refresh orders
      ref.read(orderNotifierProvider.notifier).getAllOrder();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> deleteOrder(int id) async {
    try {
      final orderRepository = ref.read(orderRepositoryProvider);
      var res = await DeleteOrderUsecase(orderRepository).call(id);

      // Refresh orders
      ref.read(orderNotifierProvider.notifier).getAllOrder();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  void onChangedUser(int? value) {
    state = state.copyWith(userId: value);
  }

  void onChangedStatus(OrderStatus? value) {
    if (value == null) return;

    state = state.copyWith(status: value.value);
  }

  void onChangedDeliveryDatetime(String value) {
    state = state.copyWith(deliveryDatetime: value);
  }

  void removeItem(int index) {
    final currentItems = state.items ?? [];

    if (index < 0 || index >= currentItems.length) return;

    final updatedItems = [...currentItems]..removeAt(index);

    state = state.copyWith(
      items: updatedItems,
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
    );
  }

  void onChangedNote(String value) {
    state = state.copyWith(note: value);
  }

  void addItem() {
    final current = state.items;
    state = state.copyWith(
      items: [...?current, OrderItemForm()],
    );
  }
}