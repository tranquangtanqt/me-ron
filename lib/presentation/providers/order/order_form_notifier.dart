import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
// import '../../../domain/usecases/storage_usecases.dart';
import '../../screens/order/components/order_item_form.dart';
import '../products/products_notifier.dart';
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
    final now = DateTime.now();
    final today = "${now.day.toString().padLeft(2, '0')}/"
        "${now.month.toString().padLeft(2, '0')}/"
        "${now.year}";

    if (orderId == null) {
      state = state.copyWith(
        deliveryDatetime: today,
        isLoaded: true,
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
        id: null,
        userId: state.userId,
        status: state.status ?? OrderStatus.shipping.value,
        deliveryDatetime: state.deliveryDatetime ?? '',
        discountValue: state.discountValue ?? 0,
        subTotal: state.subTotal ?? 0,
        total: state.total ?? 0,
        note: state.note ?? '',
      );

      var res = await CreateOrderUsecase(orderRepository).call(order);

      final orderItemRepository = ref.read(orderItemRepositoryProvider);

      var total = 0;
      for (final OrderItemForm item in state.items ?? []) {
        var oderItem = OrderItemEntity(
          orderId: res.data,
          productId: item.product?.id,
          snapshotName: item.product?.name,
          snapshotPrice: item.product?.price ?? 0,
          quantity: item.quantity,
          lineTotal: (item.product?.price ?? 0) * item.quantity
        );

        await CreateOrderItemUsecase(orderItemRepository).call(oderItem);
        total += oderItem.lineTotal;
      }

      final updatedOrder = order.copyWith(
        id: res.data,
        total: total,
      );

      await UpdateOrderUsecase(orderRepository).call(updatedOrder);

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

  void updateProduct(int index, ProductEntity? product) {
    state = state.copyWith(
      items: [
        ...?state.items,
      ]..[index] = state.items![index].copyWith(
        product: product,
      ),
    );
  }

  void onChangedNote(String value) {
    state = state.copyWith(note: value);
  }

  void addItem(ProductEntity? defaultProduct) {
    state = state.copyWith(
      items: [
        ...?state.items,
        OrderItemForm(
          product: defaultProduct,
          quantity: 1,
        ),
      ],
    );
  }
}