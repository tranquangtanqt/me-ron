import '../../core/common/result.dart';
import '../../data/models/order_item_model.dart';
import '../entities/order_item_entity.dart';

abstract class OrderItemRepository {
  Future<Result<List<OrderItemModel>>> getAllOrderItems(
    {
      String orderBy,
      String sortBy,
      int limit,
      int? offset,
      String? contains,
    });

  Future<Result<OrderItemEntity?>> getOrderItem(int orderId);

  Future<Result<int>> createOrderItem(OrderItemEntity order);

  Future<Result<void>> updateOrderItem(OrderItemEntity order);

  Future<Result<void>> deleteOrderItem(int orderId);
}
