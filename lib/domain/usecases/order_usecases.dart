import 'package:me_ron/domain/usecases/params/order_params.dart';

import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../../data/models/order_model.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

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
