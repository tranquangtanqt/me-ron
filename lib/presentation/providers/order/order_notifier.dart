import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/order_usecases.dart';
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
    state = const OrderState();
  }

  Future<void> getAllOrder({int? offset, String? contains}) async {
    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    var params = BaseParams(
      orderBy: 'id',
      sortBy: 'ASC',
      offset: offset,
      contains: contains,
    );

    final orderRepository = ref.read(orderRepositoryProvider);
    var res = await GetAllOrderUsecase(orderRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWithGroup(allOrder: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.allOrder ?? [];
        state = state.copyWithGroup(
          allOrder: [...current, ...res.data ?? []],
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: false);
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }
}
