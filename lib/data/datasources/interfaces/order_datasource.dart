import '../../../core/common/result.dart';
import '../../../domain/usecases/params/order_params.dart';
import '../../models/order_model.dart';

abstract class OrderDatasource {
  Future<Result<int>> createOrder(OrderModel order);

  Future<Result<void>> updateOrder(OrderModel order);

  Future<Result<void>> deleteOrder(int id);

  Future<Result<List<OrderModel>>> getOrder(int id);

  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params);

  Future<Result<void>> updateStatusOrder(int id, int status);
}