import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/order_item_model.dart';
import '../entities/order_item_entity.dart';
import '../repositories/order_item_repository.dart';
import 'params/base_params.dart';

class GetAllOrderItemUsecase extends Usecase<Result, BaseParams> {
  GetAllOrderItemUsecase(this._orderItemRepository);

  final OrderItemRepository _orderItemRepository;

  @override
  Future<Result<List<OrderItemModel>>> call(BaseParams params) async => _orderItemRepository.getAllOrderItems(params);
}

class GetOrderItemUsecase extends Usecase<Result, int> {
  GetOrderItemUsecase(this._orderItemRepository);

  final OrderItemRepository _orderItemRepository;

  @override
  Future<Result<OrderItemEntity?>> call(int params) async => _orderItemRepository.getOrderItem(params);
}

class CreateOrderItemUsecase extends Usecase<Result, OrderItemEntity> {
  CreateOrderItemUsecase(this._orderItemRepository);

  final OrderItemRepository _orderItemRepository;

  @override
  Future<Result<int>> call(OrderItemEntity params) async => _orderItemRepository.createOrderItem(params);
}

class UpdateOrderItemUsecase extends Usecase<Result<void>, OrderItemEntity> {
  UpdateOrderItemUsecase(this._orderItemRepository);

  final OrderItemRepository _orderItemRepository;

  @override
  Future<Result<void>> call(OrderItemEntity params) async => _orderItemRepository.updateOrderItem(params);
}

class DeleteOrderItemUsecase extends Usecase<Result<void>, int> {
  DeleteOrderItemUsecase(this._orderItemRepository);

  final OrderItemRepository _orderItemRepository;

  @override
  Future<Result<void>> call(int params) async => _orderItemRepository.deleteOrderItem(params);
}
