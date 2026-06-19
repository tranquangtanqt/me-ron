import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums/order_status.dart';
import 'order_filter_state.dart';

final orderFilterProvider = StateNotifierProvider<OrderFilterNotifier, OrderFilterState>(
      (ref) => OrderFilterNotifier(),
);

class OrderFilterNotifier extends StateNotifier<OrderFilterState> {
  OrderFilterNotifier()
      : super(OrderFilterState(
        status: OrderStatus.shipping.value,
        fromDate: DateTime.now(),
        toDate: DateTime.now(),
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
    state = OrderFilterState(
      status: OrderStatus.shipping.value,
      fromDate: DateTime.now(),
      toDate: DateTime.now(),
    );
  }
}
