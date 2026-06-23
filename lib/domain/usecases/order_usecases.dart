import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';
import '../../../domain/usecases/params/order_params.dart';

class GetAllOrderUsecase extends Usecase<Result, OrderParams> {
  GetAllOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderModel>>> call(OrderParams params) async => _orderRepository.getAllOrders(params);
}

class GetOrderUsecase extends Usecase<Result, int> {
  GetOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<List<OrderModel>>> call(int params) async => _orderRepository.getOrder(params);
}

class CreateOrderUsecase extends Usecase<Result, OrderEntity> {
  CreateOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(OrderEntity params) async => _orderRepository.createOrder(params);
}

class CreateOrderWithItemsUsecase extends Usecase<Result, Map<String, dynamic>> {
  CreateOrderWithItemsUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<int>> call(Map<String, dynamic> params) async {
    final order = params['order'] as OrderEntity;
    final items = params['items'] as List;
    return _orderRepository.createOrderWithItems(order, items);
  }
}

class UpdateOrderUsecase extends Usecase<Result<void>, OrderEntity> {
  UpdateOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(OrderEntity params) async => _orderRepository.updateOrder(params);
}

class DeleteOrderUsecase extends Usecase<Result<void>, int> {
  DeleteOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(int params) async => _orderRepository.deleteOrder(params);
}

class UpdateStatusOrderUsecase extends Usecase<Result<void>, OrderEntity> {
  UpdateStatusOrderUsecase(this._orderRepository);

  final OrderRepository _orderRepository;

  @override
  Future<Result<void>> call(OrderEntity params) async => _orderRepository.updateStatusOrder(params);
}
