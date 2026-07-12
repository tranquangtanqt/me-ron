import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../domain/usecases/order_usecases.dart';
import '../../../../domain/usecases/params/base_params.dart';
import '../../../../domain/usecases/params/report_customer_params.dart';
import 'report_customer_filter_notifier.dart';
import 'report_customer_state.dart';

final reportCustomerNotifierProvider = NotifierProvider<ReportCustomerNotifier, ReportCustomerState>(
  ReportCustomerNotifier.new,
);

class ReportCustomerNotifier extends Notifier<ReportCustomerState> {
  static const int topLimit = 100;

  @override
  ReportCustomerState build() {
    return const ReportCustomerState();
  }

  Future<void> reload() async {
    final filter = ref.read(reportCustomerFilterProvider);

    final toDate = filter.toDate == null
        ? null
        : DateTime(filter.toDate!.year, filter.toDate!.month, filter.toDate!.day, 23, 59, 59, 999);

    state = const ReportCustomerState(customers: null, error: null);

    final orderRepository = ref.read(orderRepositoryProvider);

    final params = ReportCustomerParams(
      base: const BaseParams(limit: topLimit),
      fromDate: filter.fromDate,
      toDate: toDate,
    );

    final res = await GetTopCustomersUsecase(orderRepository).call(params);

    if (res.isFailure) {
      state = state.copyWith(customers: const [], error: res.error?.toString());
      throw Exception(res.error?.toString() ?? 'Failed to load data');
    }

    state = state.copyWith(customers: res.data ?? []);
  }
}
