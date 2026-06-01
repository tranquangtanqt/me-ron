import '../../core/common/result.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Result<List<OrderModel>>> getAllOrders(
    {
      String orderBy,
      String sortBy,
      int limit,
      int? offset,
      String? contains,
    });

  Future<Result<List<OrderModel>>> getOrder(int orderId);

  Future<Result<int>> createOrder(OrderEntity order);

  Future<Result<void>> updateOrder(OrderEntity order);

  Future<Result<void>> deleteOrder(int orderId);
}
