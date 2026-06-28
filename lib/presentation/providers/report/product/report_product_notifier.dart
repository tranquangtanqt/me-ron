import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../data/models/order_model.dart';
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
  @override
  ReportProductState build() {
    return const ReportProductState();
  }

  void resetOrder() {
    state = const ReportProductState(
      allOrder: [],
      // isLoadingMore: false,
      error: null,
    );
  }

  //*************************************
  Future<void> getAllOrderReportProduct({int? offset, String? contains,
    DateTime? fromDate, DateTime? toDate, int? productId}) async {
    state = const ReportProductState(
      allOrder: [],
      // isLoadingMore: false,
      error: null,
    );

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

    final params = ReportProductParams(
      base: baseParams,
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      productId: productId,
    );

    final orderRepository = ref.read(orderRepositoryProvider);
    final res = await GetAllOrderReportProductUsecase(orderRepository).call(params);

    if (res.isSuccess) {
      final newData = res.data ?? [];

      final summary = _buildSummary(newData);

      if (offset == null) {
        state = state.copyWithGroup(
          allOrder: newData,
          productSummary: summary,
          // isLoadingMore: false,
        );
      } else {
        final currentOrder = state.allOrder ?? [];

        final merged = [...currentOrder, ...newData];

        state = state.copyWith(
          allOrder: merged,
          productSummary: _buildSummary(merged),
          // isLoadingMore: false,
        );
      }
    } else {
      // state = state.copyWith(isLoadingMore: false);
      state = state.copyWith();
      throw Exception(res.error?.toString() ?? 'Failed to load data');
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

  Map<int, ProductSummaryModel> _buildSummary(List<OrderModel>? orders) {
    if (orders == null) return {};

    return orders.fold<Map<int, ProductSummaryModel>>(
      {},
          (map, order) {
        for (final item in order.items ?? []) {
          map.update(
            item.productId,
                (value) => ProductSummaryModel(
              productId: value.productId,
              productName: value.productName,
              quantity: value.quantity + (item.quantity as int),
            ),
            ifAbsent: () => ProductSummaryModel(
              productId: item.productId,
              productName: item.snapshotName,
              quantity: item.quantity.toInt(),
            ),
          );
        }
        return map;
      },
    );
  }

}
