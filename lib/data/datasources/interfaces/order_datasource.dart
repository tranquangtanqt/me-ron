import '../../../core/common/result.dart';
import '../../../domain/usecases/params/order_params.dart';
import '../../../domain/usecases/params/report_customer_params.dart';
import '../../../domain/usecases/params/report_order_params.dart';
import '../../../domain/usecases/params/report_product_params.dart';
import '../../models/customer_summary_model.dart';
import '../../models/order_customer_summary_model.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../models/order_status_summary_model.dart';
import '../../models/product_summary_model.dart';

abstract class OrderDatasource {
  Future<Result<int>> createOrder(OrderModel order);

  Future<Result<int>> createOrderWithItems(OrderModel order, List<OrderItemModel> items);

  Future<Result<void>> updateOrderWithItems(OrderModel order, List<OrderItemModel> items);

  Future<Result<void>> updateOrder(OrderModel order);

  Future<Result<void>> deleteOrder(int id);

  Future<Result<List<OrderModel>>> getOrder(int id);

  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params);

  Future<Result<int>> getOrdersCount(OrderParams params);

  Future<Result<List<OrderModel>>> getAllOrderReportProduct(ReportProductParams params);

  Future<Result<int>> getOrdersCountReportProduct(ReportProductParams params);

  Future<Result<List<ProductSummaryModel>>> getProductSummaryReportProduct(ReportProductParams params);

  Future<Result<List<OrderModel>>> getAllOrderReportOrder(ReportOrderParams params);

  Future<Result<int>> getOrdersCountReportOrder(ReportOrderParams params);

  Future<Result<List<OrderStatusSummaryModel>>> getOrderStatusSummary(ReportOrderParams params);

  Future<Result<List<ProductSummaryModel>>> getOrderProductSummary(ReportOrderParams params);

  Future<Result<List<OrderCustomerSummaryModel>>> getCustomerSummaryReportOrder(ReportOrderParams params);

  Future<Result<List<CustomerSummaryModel>>> getTopCustomers(ReportCustomerParams params);

  Future<Result<void>> updateStatusOrder(int id, int status);
}
