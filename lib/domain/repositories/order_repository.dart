import 'package:me_ron/domain/usecases/params/order_params.dart';

import '../../core/common/result.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params);

  Future<Result<List<OrderModel>>> getOrder(int orderId);

  Future<Result<int>> createOrder(OrderEntity order);

  Future<Result<void>> updateOrder(OrderEntity order);

  Future<Result<void>> deleteOrder(int orderId);
}
