import '../../../core/common/result.dart';
import '../../models/order_model.dart';

abstract class OrderDatasource {
  Future<Result<int>> createOrder(OrderModel order);

  Future<Result<void>> updateOrder(OrderModel order);

  Future<Result<void>> deleteOrder(int id);

  Future<Result<OrderModel?>> getOrder(int id);

  Future<Result<List<OrderModel>>> getAllOrders({
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
