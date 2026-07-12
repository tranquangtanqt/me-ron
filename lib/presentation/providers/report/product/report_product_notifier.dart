import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../data/models/product_summary_model.dart';
import '../../../../domain/usecases/params/base_params.dart';
import '../../../../domain/usecases/order_usecases.dart';
import '../../../../domain/usecases/params/report_product_params.dart';
import '../../report/product/report_product_filter_notifier.dart';
import '../../../../presentation/providers/report/product/report_product_state.dart';

final reportProductNotifierProvider = NotifierProvider<ReportProductNotifier, ReportProductState>(
  ReportProductNotifier.new,
);

class ReportProductNotifier extends Notifier<ReportProductState> {
  static const int pageSize = 30;

  ReportProductParams? _lastFilter;
  bool _isFetching = false;

  @override
  ReportProductState build() {
    return const ReportProductState();
  }

  void resetOrder() {
    _lastFilter = null;
    state = const ReportProductState(
      allOrder: [],
      total: null,
      productSummary: null,
      error: null,
    );
  }

  Future<void> getAllOrderReportProduct({
    String? contains,
    DateTime? fromDate,
    DateTime? toDate,
    int? productId,
  }) async {
    _lastFilter = ReportProductParams(
      base: const BaseParams(),
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      productId: productId,
    );

    state = const ReportProductState(
      allOrder: [],
      total: null,
      productSummary: null,
      error: null,
    );

    final orderRepository = ref.read(orderRepositoryProvider);

    final countRes = await GetOrdersCountReportProductUsecase(orderRepository).call(_lastFilter!);

    if (countRes.isFailure) {
      state = state.copyWith(error: countRes.error?.toString());
      throw Exception(countRes.error?.toString() ?? 'Failed to load data');
    }

    final summaryRes = await GetProductSummaryReportProductUsecase(orderRepository).call(_lastFilter!);

    if (summaryRes.isFailure) {
      state = state.copyWith(error: summaryRes.error?.toString());
      throw Exception(summaryRes.error?.toString() ?? 'Failed to load data');
    }

    final total = countRes.data ?? 0;

    final productSummary = <int, ProductSummaryModel>{
      for (final p in summaryRes.data ?? []) (p.productId ?? 0): p,
    };

    state = state.copyWith(
      total: total,
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

      final params = ReportProductParams(
        base: baseParams,
        contains: _lastFilter!.contains,
        fromDate: _lastFilter!.fromDate,
        toDate: _lastFilter!.toDate,
        productId: _lastFilter!.productId,
      );

      final res = await GetAllOrderReportProductUsecase(orderRepository).call(params);

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

  Future<void> reloadByReportProduct() async {
    final filter = ref.read(reportProductFilterProvider);

    final toDate = DateTime(
      filter.toDate!.year,
      filter.toDate!.month,
      filter.toDate!.day,
      23,
      59,
      59,
      999,
    );

    await getAllOrderReportProduct(
      fromDate: filter.fromDate,
      toDate: toDate,
      productId: filter.productId,
    );
  }
}
