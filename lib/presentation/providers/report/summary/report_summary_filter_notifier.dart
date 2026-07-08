import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'report_summary_filter_state.dart';

final reportSummaryFilterProvider = StateNotifierProvider<ReportSummaryFilterNotifier, ReportSummaryFilterState>(
  (ref) => ReportSummaryFilterNotifier(),
);

class ReportSummaryFilterNotifier extends StateNotifier<ReportSummaryFilterState> {
  ReportSummaryFilterNotifier()
    : super(
        ReportSummaryFilterState(
          fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
          toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
        ),
      );

  void setFromDate(DateTime from) {
    state = state.copyWith(fromDate: from);
  }

  void setToDate(DateTime to) {
    state = state.copyWith(toDate: to);
  }

  void reset() {
    state = ReportSummaryFilterState(
      fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
      toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
    );
  }
}
