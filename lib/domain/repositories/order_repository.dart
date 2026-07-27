import '../../core/common/result.dart';
import '../../data/models/customer_summary_model.dart';
import '../../data/models/order_customer_summary_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/order_status_summary_model.dart';
import '../../data/models/product_summary_model.dart';
import '../entities/order_entity.dart';
import '../../domain/usecases/params/order_params.dart';
import '../usecases/params/report_customer_params.dart';
import '../usecases/params/report_order_params.dart';
import '../usecases/params/report_product_params.dart';

abstract class OrderRepository {
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

  Future<Result<List<OrderModel>>> getOrder(int orderId);

  Future<Result<int>> createOrder(OrderEntity order);

  Future<Result<int>> createOrderWithItems(OrderEntity order, List<dynamic> items);

  Future<Result<void>> updateOrder(OrderEntity order);

  Future<Result<void>> updateOrderWithItems(OrderEntity order, List<dynamic> items);

  Future<Result<void>> deleteOrder(int orderId);

  Future<Result<void>> updateStatusOrder(int orderId, int status);
}
