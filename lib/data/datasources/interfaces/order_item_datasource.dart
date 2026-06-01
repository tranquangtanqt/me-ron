import '../../../core/common/result.dart';
import '../../models/order_item_model.dart';

abstract class OrderItemDatasource {
  Future<Result<int>> createOrderItem(OrderItemModel order);

  Future<Result<void>> updateOrderItem(OrderItemModel order);

  Future<Result<void>> deleteOrderItem(int id);

  Future<Result<OrderItemModel?>> getOrderItem(int id);

  Future<Result<List<OrderItemModel>>> getAllOrderItems({
    String orderBy,
    String sortBy,
    int limit,
    int? offset,
    String? contains,
  });
}
