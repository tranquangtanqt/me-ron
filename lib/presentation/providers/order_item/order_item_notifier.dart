import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/order_item_usecases.dart';
import 'order_item_state.dart';

final orderItemNotifierProvider = NotifierProvider<OrderItemNotifier, OrderItemState>(
  OrderItemNotifier.new,
);

class OrderItemNotifier extends Notifier<OrderItemState> {
  @override
  OrderItemState build() {
    return const OrderItemState();
  }

  void resetOrderItem() {
    state = const OrderItemState();
  }

  Future<void> getAllOrderItem({int? offset, String? contains}) async {
    if (offset != null) {
      state = state.copyWith(isLoadingMore: true);
    }

    var params = BaseParams(
      orderBy: 'id',
      sortBy: 'ASC',
      offset: offset,
    );

    final orderItemRepository = ref.read(orderItemRepositoryProvider);
    var res = await GetAllOrderItemUsecase(orderItemRepository).call(params);

    if (res.isSuccess) {
      if (offset == null) {
        state = state.copyWith(allOrderItem: res.data ?? [], isLoadingMore: false);
      } else {
        final current = state.allOrderItem ?? [];
        state = state.copyWith(
          allOrderItem: [...current, ...res.data ?? []],
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(isLoadingMore: false);
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }
  }
}
