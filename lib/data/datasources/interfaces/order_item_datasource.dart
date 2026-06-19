import 'package:me_ron/domain/usecases/params/base_params.dart';

import '../../../core/common/result.dart';
import '../../models/order_item_model.dart';

abstract class OrderItemDatasource {
  Future<Result<int>> createOrderItem(OrderItemModel order);

  Future<Result<void>> updateOrderItem(OrderItemModel order);

  Future<Result<void>> deleteOrderItem(int id);

  Future<Result<OrderItemModel?>> getOrderItem(int id);

  Future<Result<List<OrderItemModel>>> getAllOrderItems(BaseParams params);
}
