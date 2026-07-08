import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'purchase_filter_state.dart';

final purchaseFilterProvider = StateNotifierProvider<PurchaseFilterNotifier, PurchaseFilterState>(
  (ref) => PurchaseFilterNotifier(),
);

class PurchaseFilterNotifier extends StateNotifier<PurchaseFilterState> {
  PurchaseFilterNotifier()
    : super(
        PurchaseFilterState(
          fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
          toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
        ),
      );

  void setFromDate(
    DateTime from,
  ) {
    state = state.copyWith(fromDate: from);
  }

  void setToDate(DateTime to) {
    state = state.copyWith(toDate: to);
  }

  void reset() {
    state = PurchaseFilterState(
      fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
      toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
    );
  }
}
