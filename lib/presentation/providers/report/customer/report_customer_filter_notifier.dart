import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'report_customer_filter_state.dart';

final reportCustomerFilterProvider = StateNotifierProvider<ReportCustomerFilterNotifier, ReportCustomerFilterState>(
  (ref) => ReportCustomerFilterNotifier(),
);

class ReportCustomerFilterNotifier extends StateNotifier<ReportCustomerFilterState> {
  ReportCustomerFilterNotifier() : super(const ReportCustomerFilterState());

  void setFromDate(DateTime from) {
    state = state.copyWith(fromDate: from);
  }

  void setToDate(DateTime to) {
    state = state.copyWith(toDate: to);
  }

  void clearDates() {
    state = const ReportCustomerFilterState();
  }
}
