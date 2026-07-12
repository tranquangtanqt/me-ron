import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../data/models/order_status_summary_model.dart';
import '../../../../data/models/product_summary_model.dart';
import '../../../../domain/usecases/params/base_params.dart';
import '../../../../domain/usecases/order_usecases.dart';
import '../../../../domain/usecases/params/report_order_params.dart';
import '../../../../presentation/providers/report/order/report_order_filter_notifier.dart';
import '../../../../presentation/providers/report/order/report_order_state.dart';

final reportOrderNotifierProvider = NotifierProvider<ReportOrderNotifier, ReportOrderState>(
  ReportOrderNotifier.new,
);

class ReportOrderNotifier extends Notifier<ReportOrderState> {
  static const int pageSize = 30;

  ReportOrderParams? _lastFilter;
  bool _isFetching = false;

  @override
  ReportOrderState build() {
    return const ReportOrderState();
  }

  void resetOrder() {
    _lastFilter = null;
    state = const ReportOrderState(
      allOrder: [],
      total: null,
      productSummary: null,
      orderStatusSummary: null,
      error: null,
    );
  }

  Future<void> getAllOrderReportOrder({
    String? contains,
    DateTime? fromDate,
    DateTime? toDate,
    int? status,
    int? userId,
  }) async {
    _lastFilter = ReportOrderParams(
      base: const BaseParams(),
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      userId: userId,
    );

    state = const ReportOrderState(
      allOrder: [],
      total: null,
      productSummary: null,
      orderStatusSummary: null,
      error: null,
    );

    final orderRepository = ref.read(orderRepositoryProvider);

    final countRes = await GetOrdersCountReportOrderUsecase(orderRepository).call(_lastFilter!);

    if (countRes.isFailure) {
      state = state.copyWith(error: countRes.error?.toString());
      throw Exception(countRes.error?.toString() ?? 'Failed to load data');
    }

    final statusSummaryRes = await GetOrderStatusSummaryUsecase(orderRepository).call(_lastFilter!);
    final productSummaryRes = await GetOrderProductSummaryUsecase(orderRepository).call(_lastFilter!);

    if (statusSummaryRes.isFailure) {
      state = state.copyWith(error: statusSummaryRes.error?.toString());
      throw Exception(statusSummaryRes.error?.toString() ?? 'Failed to load data');
    }

    if (productSummaryRes.isFailure) {
      state = state.copyWith(error: productSummaryRes.error?.toString());
      throw Exception(productSummaryRes.error?.toString() ?? 'Failed to load data');
    }

    final total = countRes.data ?? 0;

    final orderStatusSummary = <int, OrderStatusSummaryModel>{
      for (final s in statusSummaryRes.data ?? []) s.status: s,
    };

    final productSummary = <int, ProductSummaryModel>{
      for (final p in productSummaryRes.data ?? []) (p.productId ?? 0): p,
    };

    state = state.copyWith(
      total: total,
      orderStatusSummary: orderStatusSummary,
      productSummary: productSummary,
    );

    if (total == 0) return;

    while ((state.allOrder?.length ?? 0) < (state.total ?? 0) && (state.total ?? 0) <= pageSize) {
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

      final params = ReportOrderParams(
        base: baseParams,
        contains: _lastFilter!.contains,
        fromDate: _lastFilter!.fromDate,
        toDate: _lastFilter!.toDate,
        status: _lastFilter!.status,
        userId: _lastFilter!.userId,
      );

      final res = await GetAllOrderReportOrderUsecase(orderRepository).call(params);

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

  Future<void> reloadByReportOrder() async {
    final filter = ref.read(reportOrderFilterProvider);

    final toDate = DateTime(
      filter.toDate!.year,
      filter.toDate!.month,
      filter.toDate!.day,
      23,
      59,
      59,
      999,
    );

    await getAllOrderReportOrder(
      fromDate: filter.fromDate,
      toDate: toDate,
      status: filter.status,
      userId: filter.userId,
    );
  }
}
