import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/order_item_model.dart';
import '../entities/order_item_entity.dart';
import '../repositories/order_item_repository.dart';
import 'params/base_params.dart';

class GetAllOrderItemUsecase extends Usecase<Result, BaseParams> {
  GetAllOrderItemUsecase(this._orderRepository);

  final OrderItemRepository _orderRepository;

  @override
  Future<Result<List<OrderItemModel>>> call(BaseParams params) async => _orderRepository.getAllOrderItems(
    orderBy: params.orderBy,
    sortBy: params.sortBy,
    limit: params.limit,
    offset: params.offset,
    contains: params.contains,
  );
}

class GetOrderItemUsecase extends Usecase<Result, int> {
  GetOrderItemUsecase(this._orderRepository);

  final OrderItemRepository _orderRepository;

  @override
  Future<Result<OrderItemEntity?>> call(int params) async => _orderRepository.getOrderItem(params);
}

class CreateOrderItemUsecase extends Usecase<Result, OrderItemEntity> {
  CreateOrderItemUsecase(this._orderRepository);

  final OrderItemRepository _orderRepository;

  @override
  Future<Result<int>> call(OrderItemEntity params) async => _orderRepository.createOrderItem(params);
}

class UpdateOrderItemUsecase extends Usecase<Result<void>, OrderItemEntity> {
  UpdateOrderItemUsecase(this._orderRepository);

  final OrderItemRepository _orderRepository;

  @override
  Future<Result<void>> call(OrderItemEntity params) async => _orderRepository.updateOrderItem(params);
}

class DeleteOrderItemUsecase extends Usecase<Result<void>, int> {
  DeleteOrderItemUsecase(this._orderRepository);

  final OrderItemRepository _orderRepository;

  @override
  Future<Result<void>> call(int params) async => _orderRepository.deleteOrderItem(params);
}
