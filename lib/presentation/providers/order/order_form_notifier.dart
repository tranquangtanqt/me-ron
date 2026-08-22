import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../core/enums/order_status.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/order_item_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/order_item_usecases.dart';
import '../../../domain/usecases/order_usecases.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/params/order_params.dart';
import '../base/base_form_notifier.dart';
import '../../screens/order/components/order_item_form.dart';
import '../products/products_notifier.dart';
import 'order_form_state.dart';
import 'order_notifier.dart';

final orderFormNotifierProvider = NotifierProvider.autoDispose<OrderFormNotifier, OrderFormState>(
  OrderFormNotifier.new,
);

int calculateOrderItemPrice(OrderItemForm item, {Map<int, int>? disabledProductSnapshotPrices}) {
  if (item.isFreeItem) {
    return item.freeItemPrice ?? 0;
  }

  if (disabledProductSnapshotPrices != null &&
      item.product != null &&
      item.product!.id != null &&
      disabledProductSnapshotPrices.containsKey(item.product!.id)) {
    return disabledProductSnapshotPrices[item.product!.id] ?? item.product!.price;
  }

  return item.product?.price ?? 0;
}

int calculateOrderItemLineTotal(OrderItemForm item, {Map<int, int>? disabledProductSnapshotPrices}) {
  return calculateOrderItemPrice(item, disabledProductSnapshotPrices: disabledProductSnapshotPrices) * item.quantity;
}

class OrderFormNotifier extends BaseFormNotifier<OrderFormState> {
  @override
  OrderFormState build() {
    return const OrderFormState();
  }

  Future<void> initOrderForm(int? orderId) async {
    final now = DateTime.now();

    if (orderId == null) {
      state = state.copyWith(
        deliveryDatetime: now,
        discountValue: 0,
        subTotal: 0,
        total: 0,
        isLoaded: true,
        status: OrderStatus.shipping.value,
        originalStatus: OrderStatus.shipping.value,
      );
      return;
    }

    final orderRepository = ref.read(orderRepositoryProvider);
    var res = await GetOrderUsecase(orderRepository).call(orderId);

    final allProduct = ref.read(productsNotifierProvider).allProducts ?? [];

    if (res.isSuccess) {
      List<OrderModel>? orders = res.data;

      state = state.copyWith(
        userId: orders?[0].userId,
        status: orders?[0].status,
        originalStatus: orders?[0].status,
        deliveryDatetime: orders?[0].deliveryDatetime,
        isPrepaid: OrderStatusExtension.fromValue(orders?[0].status ?? 0) == OrderStatus.completed,
        paymentDatetime: orders?[0].paymentDatetime,
        discountValue: orders?[0].discountValue,
        subTotal: orders?[0].subTotal,
        total: orders?[0].total,
        note: orders?[0].note,
        isLoaded: true,
      );

      for (OrderModel order in orders ?? []) {
        ProductEntity? matchedProduct;
        for (final p in allProduct) {
          if (p.id == order.productId) {
            matchedProduct = p;
            break;
          }
        }

        final isFreeItem = order.productId == null || matchedProduct == null;

        final item = OrderItemForm(
          id: order.orderItemId,
          product: matchedProduct,
          quantity: order.quantity ?? 0,
          snapshotPrice: order.snapshotPrice,
          originalProductId: order.productId,
          isFreeItem: isFreeItem,
          freeItemName: isFreeItem ? order.snapshotName : null,
          freeItemPrice: isFreeItem ? order.snapshotPrice : null,
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

  Future<bool> hasOrderTodayForUser({int? excludeOrderId}) async {
    final userId = state.userId;
    final deliveryDatetime = state.deliveryDatetime;

    if (userId == null || deliveryDatetime == null) return false;

    final fromDate = DateTime(deliveryDatetime.year, deliveryDatetime.month, deliveryDatetime.day);
    final toDate = DateTime(deliveryDatetime.year, deliveryDatetime.month, deliveryDatetime.day, 23, 59, 59, 999);

    final orderRepository = ref.read(orderRepositoryProvider);

    final res = await GetAllOrderUsecase(orderRepository).call(
      OrderParams(
        base: const BaseParams(limit: 50, offset: 0),
        userId: userId,
        fromDate: fromDate,
        toDate: toDate,
      ),
    );

    if (res.isFailure) return false;

    final orders = res.data ?? [];

    return orders.any((o) => o.id != excludeOrderId && o.status != OrderStatus.cancelled.value);
  }

  Future<Result<int>> createOrder() async {
    return performCreate(
      execute: () async {
        _validateItems(state.items ?? []);

        final orderRepository = ref.read(orderRepositoryProvider);

        final order = OrderEntity(
          id: null,
          userId: state.userId,
          status: state.isPrepaid ? OrderStatus.completed.value : OrderStatus.shipping.value,
          deliveryDatetime: state.deliveryDatetime,
          paymentDatetime: state.paymentDatetime,
          discountValue: state.discountValue ?? 0,
          subTotal: state.subTotal ?? 0,
          total: state.total ?? 0,
          note: state.note ?? '',
        );

        // create order + items atomically (local + queued action)
        final disabledProductSnapshotPrices = _getDisabledProductSnapshotPrices(state.items ?? []);
        final items = <OrderItemEntity>[];
        for (final OrderItemForm item in state.items ?? []) {
          final oderItem = OrderItemEntity(
            orderId: null,
            productId: item.isFreeItem ? null : item.product?.id,
            snapshotName: item.isFreeItem ? item.freeItemName : item.product?.name,
            snapshotPrice: calculateOrderItemPrice(item, disabledProductSnapshotPrices: disabledProductSnapshotPrices),
            quantity: item.quantity,
            lineTotal: calculateOrderItemLineTotal(item, disabledProductSnapshotPrices: disabledProductSnapshotPrices),
          );
          items.add(oderItem);
        }

        final res = await CreateOrderWithItemsUsecase(orderRepository).call({
          'order': order,
          'items': items,
        });

        return res;
      },
      onSuccess: () => ref.read(orderNotifierProvider.notifier).getAllOrder(true),
    );
  }

  Future<Result<void>> updatedOrder(int id) async {
    return performUpdate(
      execute: () async {
        _validateItems(state.items ?? []);

        final orderRepository = ref.read(orderRepositoryProvider);

        final order = OrderEntity(
          id: id,
          userId: state.userId,
          status: state.isPrepaid ? OrderStatus.completed.value : OrderStatus.shipping.value,
          deliveryDatetime: state.deliveryDatetime,
          paymentDatetime: state.paymentDatetime,
          discountValue: state.discountValue ?? 0,
          subTotal: state.subTotal ?? 0,
          total: state.total ?? 0,
          note: state.note ?? '',
        );

        final disabledProductSnapshotPrices = _getDisabledProductSnapshotPrices(state.items ?? []);
        final items = <OrderItemEntity>[];
        for (final OrderItemForm item in state.items ?? []) {
          items.add(
            OrderItemEntity(
              id: item.id,
              orderId: id,
              productId: item.isFreeItem ? null : item.product?.id,
              snapshotName: item.isFreeItem ? item.freeItemName : item.product?.name,
              snapshotPrice: calculateOrderItemPrice(
                item,
                disabledProductSnapshotPrices: disabledProductSnapshotPrices,
              ),
              quantity: item.quantity,
              lineTotal: calculateOrderItemLineTotal(
                item,
                disabledProductSnapshotPrices: disabledProductSnapshotPrices,
              ),
            ),
          );
        }

        final res = await UpdateOrderWithItemsUsecase(orderRepository).call({
          'order': order,
          'items': items,
        });

        return res;
      },
      onSuccess: () => ref.read(orderNotifierProvider.notifier).getAllOrder(true),
    );
  }

  Future<Result<void>> updatedStatusOrder(int id, int status) async {
    return performUpdate(
      execute: () async {
        final orderRepository = ref.read(orderRepositoryProvider);

        final res = await UpdateStatusOrderUsecase(orderRepository).call({
          'orderId': id,
          'status': status,
        });

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

  void onClear() {
    state = state.copyWith(userId: null);
  }

  // void onChangedStatus(OrderStatus? value) {
  //   if (value == null) return;
  //
  //   state = state.copyWith(status: value.value);
  // }

  void onChangedDiscountValue(String value) {
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

  void onChangedPaymentDatetime(DateTime value) {
    state = state.copyWith(paymentDatetime: value);
  }

  void onChangedPrepaid(bool value) {
    state = state.copyWith(
      isPrepaid: value,
      paymentDatetime: value ? state.paymentDatetime : null,
    );
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

  void _validateItems(List<OrderItemForm> items) {
    for (final item in items) {
      if (!item.isFreeItem) continue;

      if ((item.freeItemName ?? '').trim().isEmpty) {
        throw OrderItemValidationException(
          itemLocalKey: item.localKey,
          field: FreeItemValidationField.name,
          message: 'Vui lòng nhập tên cho món tự do',
        );
      }

      if ((item.freeItemPrice ?? 0) <= 0) {
        throw OrderItemValidationException(
          itemLocalKey: item.localKey,
          field: FreeItemValidationField.price,
          message: 'Vui lòng nhập đơn giá hợp lệ cho món tự do',
        );
      }
    }
  }

  Map<int, int> _getDisabledProductSnapshotPrices(List<OrderItemForm> items) {
    final disabledProductSnapshotPrices = <int, int>{};

    for (final item in items) {
      final productId = item.product?.id;

      if (productId != null &&
          item.snapshotPrice != null &&
          item.originalProductId != null &&
          productId == item.originalProductId &&
          item.snapshotPrice != item.product!.price) {
        disabledProductSnapshotPrices[productId] = item.snapshotPrice!;
      }
    }

    return disabledProductSnapshotPrices;
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

  void addFreeItem() {
    final items = [
      ...?state.items,
      OrderItemForm(
        isFreeItem: true,
        quantity: 1,
        freeItemPrice: 0,
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

  void updateFreeItemName(int index, String name) {
    final items = [...?state.items];

    if (index < 0 || index >= items.length) return;

    items[index] = items[index].copyWith(freeItemName: name);

    state = state.copyWith(items: items);
  }

  void updateFreeItemPrice(int index, int price) {
    final items = [...?state.items];

    if (index < 0 || index >= items.length) return;

    items[index] = items[index].copyWith(freeItemPrice: price);

    state = state.copyWith(
      items: items,
      subTotal: _calcSubTotal(items),
      total: _calcTotal(
        _calcSubTotal(items),
        state.discountValue ?? 0,
      ),
    );
  }

  int _calcSubTotal(List<OrderItemForm> items) {
    final disabledProductSnapshotPrices = _getDisabledProductSnapshotPrices(items);

    int total = 0;

    for (final item in items) {
      int totalLineItem = calculateOrderItemLineTotal(
        item,
        disabledProductSnapshotPrices: disabledProductSnapshotPrices,
      );
      total += totalLineItem;
    }

    return total;
  }

  int _calcTotal(int subTotal, int discountValue) {
    final result = subTotal - discountValue;
    return result < 0 ? 0 : result;
  }
}
