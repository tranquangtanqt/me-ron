import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:me_ron/presentation/providers/report/product/report_product_filter_state.dart';
import '../../../../core/enums/order_status.dart';


final reportProductFilterProvider = StateNotifierProvider<ReportProductNotifier, ReportProductFilterState>(
      (ref) => ReportProductNotifier(),
);

class ReportProductNotifier extends StateNotifier<ReportProductFilterState> {

  ReportProductNotifier()
      : super(ReportProductFilterState(
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

  void setProduct(int? productId) {
    state = state.copyWith(productId: productId);
  }

  void reset() {
    state = ReportProductFilterState(
      status: OrderStatus.shipping.value,
      fromDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 00, 00, 00, 000),
      toDate: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 23, 59, 59, 999),
    );
  }
}
