import '../../core/common/result.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';
import '../usecases/params/base_params.dart';

abstract class OrderRepository {
  Future<Result<List<OrderModel>>> getAllOrders(BaseParams params);

  Future<Result<List<OrderModel>>> getOrder(int orderId);

  Future<Result<int>> createOrder(OrderEntity order);

  Future<Result<void>> updateOrder(OrderEntity order);

  Future<Result<void>> deleteOrder(int orderId);
}
