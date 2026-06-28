import '../../core/common/result.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';
import '../../domain/usecases/params/order_params.dart';
import '../usecases/params/report_product_params.dart';

abstract class OrderRepository {
  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params);

  Future<Result<List<OrderModel>>> getAllOrderReportProduct(ReportProductParams params);

  Future<Result<List<OrderModel>>> getOrder(int orderId);

  Future<Result<int>> createOrder(OrderEntity order);

  Future<Result<int>> createOrderWithItems(OrderEntity order, List<dynamic> items);

  Future<Result<void>> updateOrder(OrderEntity order);

  Future<Result<void>> updateOrderWithItems(OrderEntity order, List<dynamic> items);

  Future<Result<void>> deleteOrder(int orderId);

  Future<Result<void>> updateStatusOrder(int orderId, int status);
}
