import '../../core/common/result.dart';
import '../../data/models/order_item_model.dart';
import '../entities/order_item_entity.dart';
import '../../../domain/usecases/params/base_params.dart';

abstract class OrderItemRepository {
  Future<Result<List<OrderItemModel>>> getAllOrderItems(BaseParams params);

  Future<Result<OrderItemEntity?>> getOrderItem(int orderId);

  Future<Result<int>> createOrderItem(OrderItemEntity order);

  Future<Result<void>> updateOrderItem(OrderItemEntity order);

  Future<Result<void>> deleteOrderItem(int orderId);
}
