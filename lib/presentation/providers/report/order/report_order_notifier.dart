import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../data/models/order_model.dart';
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
  @override
  ReportOrderState build() {
    return const ReportOrderState();
  }

  void resetOrder() {
    state = const ReportOrderState(
      allOrder: [],
      // isLoadingMore: false,
      error: null,
    );
  }

  //*************************************
  Future<void> getAllOrderReportOrder({int? offset, String? contains,
    DateTime? fromDate, DateTime? toDate, int? status, int? userId}) async {
    state = const ReportOrderState(
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

    final params = ReportOrderParams(
      base: baseParams,
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      userId: userId,
    );

    final orderRepository = ref.read(orderRepositoryProvider);
    final res = await GetAllOrderReportOrderUsecase(orderRepository).call(params);

    if (res.isSuccess) {
      final newData = res.data ?? [];

      final productSummary = _buildProductSummary(newData);

      if (offset == null) {
        state = state.copyWithGroup(
          allOrder: newData,
          productSummary: productSummary,
          // isLoadingMore: false,
        );
      } else {
        final currentOrder = state.allOrder ?? [];

        final merged = [...currentOrder, ...newData];

        state = state.copyWith(
          allOrder: merged,
          productSummary: _buildProductSummary(merged),
          // isLoadingMore: false,
        );
      }
    } else {
      // state = state.copyWith(isLoadingMore: false);
      state = state.copyWith();
      throw Exception(res.error?.toString() ?? 'Failed to load data');
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

  Map<int, ProductSummaryModel> _buildProductSummary(List<OrderModel>? orders) {
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
