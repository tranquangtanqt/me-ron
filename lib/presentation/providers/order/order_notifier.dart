import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/enums/order_status.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/order_usecases.dart';
import '../../../domain/usecases/params/order_params.dart';
import 'order_state.dart';

final orderNotifierProvider = NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);

class OrderNotifier extends Notifier<OrderState> {
  @override
  OrderState build() {
    return const OrderState();
  }

  void resetOrder() {
    state = const OrderState(
      allOrder: [],
      // isLoadingMore: false,
      error: null,
    );
  }

  Future<void> getAllOrder(bool resetDataFlg, {int? offset, String? contains,
  DateTime? fromDate, DateTime? toDate, int? status, int? userId}) async {
    if (resetDataFlg == true) {
      state = const OrderState(
        allOrder: [],
        // isLoadingMore: false,
        error: null,
      );
    }

    status ??= OrderStatus.shipping.value;

    if (status == -1) {
      status = null;
    }

    // if (offset != null && state.isLoadingMore) return;

    if (offset != null) {
      // state = state.copyWith(isLoadingMore: true);
      state = state.copyWith();
    }

    final baseParams = BaseParams(
      orderBy: 'id',
      sortBy: 'ASC',
      offset: offset,
    );

    final params = OrderParams(
      base: baseParams,
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      userId: userId,
    );

    final orderRepository = ref.read(orderRepositoryProvider);
    final res = await GetAllOrderUsecase(orderRepository).call(params);

    if (res.isSuccess) {
      final newData = res.data ?? [];

      if (offset == null) {
        state = state.copyWithGroup(
          allOrder: newData,
          isLoadingMore: false,
        );
      } else {
        final current = state.allOrder ?? [];

        state = state.copyWith(
          allOrder: [
            ...current,
            ...newData,
          ],
          // isLoadingMore: false,
        );
      }
    } else {
      // state = state.copyWith(isLoadingMore: false);
      state = state.copyWith();
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }
}
