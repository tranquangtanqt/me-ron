import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../presentation/providers/report/order/report_order_filter_state.dart';
import '../../../../core/enums/order_status.dart';


final reportOrderFilterProvider = StateNotifierProvider<ReportOrderNotifier, ReportOrderFilterState>(
      (ref) => ReportOrderNotifier(),
);

class ReportOrderNotifier extends StateNotifier<ReportOrderFilterState> {

  ReportOrderNotifier()
      : super(ReportOrderFilterState(
        status: OrderStatus.shipping.value,
        fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
        toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
    ),
  );

  void setStatus(int status) {
    state = state.copyWith(status: status);
  }

  void setFromDate(DateTime from, ) {
    state = state.copyWith(fromDate: from);
  }

  void setToDate(DateTime to) {
    state = state.copyWith(toDate: to);
  }

  void setUser(int? userId) {
    state = state.copyWith(userId: userId);
  }

  void reset() {
    state = ReportOrderFilterState(
      status: OrderStatus.shipping.value,
      fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
      toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
    );
  }
}
