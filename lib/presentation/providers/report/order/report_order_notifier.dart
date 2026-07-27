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
  @override
  ReportOrderState build() {
    return const ReportOrderState();
  }

  void resetOrder() {
    state = const ReportOrderState(
      customerSummary: null,
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
    final filter = ReportOrderParams(
      base: const BaseParams(),
      contains: contains,
      fromDate: fromDate,
      toDate: toDate,
      status: status,
      userId: userId,
    );

    state = const ReportOrderState(
      customerSummary: null,
      total: null,
      productSummary: null,
      orderStatusSummary: null,
      error: null,
    );

    final orderRepository = ref.read(orderRepositoryProvider);

    final countRes = await GetOrdersCountReportOrderUsecase(orderRepository).call(filter);

    if (countRes.isFailure) {
      state = state.copyWith(error: countRes.error?.toString());
      throw Exception(countRes.error?.toString() ?? 'Failed to load data');
    }

    final statusSummaryRes = await GetOrderStatusSummaryUsecase(orderRepository).call(filter);
    final productSummaryRes = await GetOrderProductSummaryUsecase(orderRepository).call(filter);
    final customerSummaryRes = await GetCustomerSummaryReportOrderUsecase(orderRepository).call(filter);

    if (statusSummaryRes.isFailure) {
      state = state.copyWith(error: statusSummaryRes.error?.toString());
      throw Exception(statusSummaryRes.error?.toString() ?? 'Failed to load data');
    }

    if (productSummaryRes.isFailure) {
      state = state.copyWith(error: productSummaryRes.error?.toString());
      throw Exception(productSummaryRes.error?.toString() ?? 'Failed to load data');
    }

    if (customerSummaryRes.isFailure) {
      state = state.copyWith(error: customerSummaryRes.error?.toString());
      throw Exception(customerSummaryRes.error?.toString() ?? 'Failed to load data');
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
      customerSummary: customerSummaryRes.data ?? [],
    );
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
