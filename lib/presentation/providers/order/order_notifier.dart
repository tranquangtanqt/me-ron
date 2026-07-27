import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/enums/order_status.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/order_usecases.dart';
import '../../../domain/usecases/params/order_params.dart';
import 'order_filter_notifier.dart';
import 'order_state.dart';

final orderNotifierProvider = NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);

// Separate instance/state for the order detail screen, which needs the
// full (unpaginated) matching order list independently of the list screen.
final orderDetailNotifierProvider = NotifierProvider<OrderNotifier, OrderState>(
  OrderNotifier.new,
);

class OrderNotifier extends Notifier<OrderState> {
  static const int pageSize = 30;

  OrderParams? _lastFilter;
  bool _isFetching = false;

  @override
  OrderState build() {
    return const OrderState();
  }

  void resetOrder() {
    _lastFilter = null;
    state = const OrderState(
      allOrder: [],
      total: null,
      error: null,
    );
  }

  Future<void> getAllOrder(
    bool resetDataFlg, {
    String? contains,
    DateTime? fromDate,
    DateTime? toDate,
    int? status,
    int? userId,
    bool loadAll = false,
  }) async {
    status ??= OrderStatus.shipping.value;

    if (status == -1) {
      status = null;
    }

    _lastFilter = OrderParams(
      base: const BaseParams(),
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      userId: userId,
    );

    if (!resetDataFlg) return;

    state = const OrderState(
      allOrder: [],
      total: null,
      error: null,
    );

    final orderRepository = ref.read(orderRepositoryProvider);
    final countRes = await GetOrdersCountUsecase(orderRepository).call(_lastFilter!);

    if (countRes.isFailure) {
      state = state.copyWith(error: countRes.error?.toString());
      throw Exception(countRes.error?.toString() ?? 'Failed to load data');
    }

    final total = countRes.data ?? 0;
    state = state.copyWith(total: total);

    if (total == 0) return;

    if (total > pageSize && !loadAll) return;

    while ((state.allOrder?.length ?? 0) < (state.total ?? 0)) {
      final before = state.allOrder?.length ?? 0;

      await loadMore();

      if ((state.allOrder?.length ?? 0) <= before) break;
    }
  }

  Future<void> loadMore() async {
    if (_isFetching || _lastFilter == null) return;

    final total = state.total ?? 0;
    final current = state.allOrder ?? [];

    if (total == 0 || current.length >= total) return;

    _isFetching = true;

    try {
      final orderRepository = ref.read(orderRepositoryProvider);

      final baseParams = BaseParams(
        orderBy: 'id',
        sortBy: 'ASC',
        limit: pageSize,
        offset: current.length,
      );

      final params = OrderParams(
        base: baseParams,
        contains: _lastFilter!.contains,
        fromDate: _lastFilter!.fromDate,
        toDate: _lastFilter!.toDate,
        status: _lastFilter!.status,
        userId: _lastFilter!.userId,
      );

      final res = await GetAllOrderUsecase(orderRepository).call(params);

      if (res.isFailure) {
        state = state.copyWith(error: res.error?.toString());
        throw Exception(res.error?.toString() ?? 'Failed to load data');
      }

      state = state.copyWithGroup(
        newRows: res.data ?? [],
        append: current.isNotEmpty,
      );
    } finally {
      _isFetching = false;
    }
  }

  Future<void> reload({bool loadAll = false}) async {
    final filter = ref.read(orderFilterProvider);

    final toDate = DateTime(
      filter.toDate!.year,
      filter.toDate!.month,
      filter.toDate!.day,
      23,
      59,
      59,
      999,
    );

    await getAllOrder(
      true,
      fromDate: filter.fromDate,
      toDate: toDate,
      status: filter.status,
      userId: filter.userId,
      loadAll: loadAll,
    );
  }

  // Loads orders using an explicit filter instead of [orderFilterProvider], so callers
  // (e.g. drilling down from a report screen) don't leak into the shared Orders tab filter.
  Future<void> reloadWithFilter({
    DateTime? fromDate,
    DateTime? toDate,
    int? status,
    int? userId,
    bool loadAll = false,
  }) async {
    await getAllOrder(
      true,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      userId: userId,
      loadAll: loadAll,
    );
  }
}
