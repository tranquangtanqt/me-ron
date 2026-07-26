import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/app_providers.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/models/product_summary_model.dart';
import '../../../../data/models/purchase_item_summary_model.dart';
import '../../../../data/models/purchase_model.dart';
import '../../../../domain/usecases/order_usecases.dart';
import '../../../../domain/usecases/params/base_params.dart';
import '../../../../domain/usecases/params/purchase_params.dart';
import '../../../../domain/usecases/params/report_order_params.dart';
import '../../../../domain/usecases/purchase_usecases.dart';
import '../../purchase/purchase_state.dart';
import '../order/report_order_state.dart';
import 'report_summary_filter_notifier.dart';
import 'report_summary_state.dart';

final reportSummaryNotifierProvider = NotifierProvider<ReportSummaryNotifier, ReportSummaryState>(
  ReportSummaryNotifier.new,
);

class ReportSummaryNotifier extends Notifier<ReportSummaryState> {
  @override
  ReportSummaryState build() {
    return const ReportSummaryState();
  }

  Future<void> reload() async {
    final filter = ref.read(reportSummaryFilterProvider);

    final toDate = DateTime(
      filter.toDate!.year,
      filter.toDate!.month,
      filter.toDate!.day,
      23,
      59,
      59,
      999,
    );

    state = const ReportSummaryState();

    final baseParams = BaseParams(orderBy: 'id', sortBy: 'ASC');

    final orderRepository = ref.read(orderRepositoryProvider);

    final countRes = await GetOrdersCountReportOrderUsecase(orderRepository).call(
      ReportOrderParams(base: baseParams, fromDate: filter.fromDate, toDate: toDate),
    );
    final total = countRes.data ?? 0;

    List<OrderModel> allOrder = [];

    if (total > 0) {
      final orderRes = await GetAllOrderReportOrderUsecase(orderRepository).call(
        ReportOrderParams(
          base: BaseParams(orderBy: 'id', sortBy: 'ASC', limit: total),
          fromDate: filter.fromDate,
          toDate: toDate,
        ),
      );

      allOrder = const ReportOrderState().copyWithGroup(newRows: orderRes.data ?? [], append: false).allOrder ?? [];
    }

    final productSummary = _buildProductSummary(allOrder);

    final purchaseRepository = ref.read(purchaseRepositoryProvider);
    final purchaseRes = await GetAllPurchaseUsecase(purchaseRepository).call(
      PurchaseParams(base: baseParams, fromDate: filter.fromDate, toDate: toDate),
    );

    final List<PurchaseModel> allPurchase =
        const PurchaseState().copyWithGroup(allPurchase: purchaseRes.data ?? []).allPurchase ?? [];
    final purchaseItemSummary = _buildPurchaseItemSummary(allPurchase);

    state = state.copyWith(
      allOrder: allOrder,
      productSummary: productSummary,
      allPurchase: allPurchase,
      purchaseItemSummary: purchaseItemSummary,
    );
  }

  Map<int, ProductSummaryModel> _buildProductSummary(List<OrderModel> orders) {
    return orders.fold<Map<int, ProductSummaryModel>>({}, (map, order) {
      for (final item in order.items ?? []) {
        map.update(
          item.productId,
          (value) => ProductSummaryModel(
            productId: value.productId,
            productName: value.productName,
            quantity: value.quantity + (item.quantity as int),
            totalAmount: value.totalAmount + item.lineTotal,
          ),
          ifAbsent: () => ProductSummaryModel(
            productId: item.productId,
            productName: item.snapshotName,
            quantity: item.quantity.toInt(),
            totalAmount: item.lineTotal,
          ),
        );
      }
      return map;
    });
  }

  Map<String, PurchaseItemSummaryModel> _buildPurchaseItemSummary(List<PurchaseModel> purchases) {
    final Map<String, PurchaseItemSummaryModel> summary = {};

    for (final purchase in purchases) {
      for (final item in purchase.items ?? []) {
        final name = item.name ?? '';
        final int price = item.price ?? 0;

        summary.update(
          name,
          (PurchaseItemSummaryModel value) {
            final int updatedTotal = value.totalAmount + price;

            return PurchaseItemSummaryModel(
              itemName: value.itemName,
              totalAmount: updatedTotal,
              count: value.count + 1,
            );
          },
          ifAbsent: () => PurchaseItemSummaryModel(
            itemName: name,
            totalAmount: price,
            count: 1,
          ),
        );
      }
    }

    return summary;
  }
}
