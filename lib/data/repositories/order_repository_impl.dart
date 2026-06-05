import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/constants/constants.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/params/base_params.dart';
import '../datasources/local/order_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/order_model.dart';
import '../models/queued_action_model.dart';

class OrderRepositoryImpl extends OrderRepository {
  final OrderLocalDatasourceImpl orderLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  OrderRepositoryImpl({
    required this.orderLocalDatasource,
    required this.queuedActionLocalDatasource,
  });


  @override
  Future<Result<List<OrderModel>>> getAllOrders(BaseParams params) async {
    try {
      final local = await orderLocalDatasource.getAllOrders(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      // return Result.success(data: list.map((e) => e.toEntity()).toList());
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderModel>>> getOrder(int orderId) async {
    try {
      final local = await orderLocalDatasource.getOrder(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createOrder(OrderEntity order) async {
    try {
      final data = OrderModel.fromEntity(order);

      final local = await orderLocalDatasource.createOrder(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'createOrder',
          param: jsonEncode((data).toJson()),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteOrder(int orderId) async {
    try {
      final local = await orderLocalDatasource.deleteOrder(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'deleteOrder',
          param: orderId.toString(),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateOrder(OrderEntity order) async {
    try {
      final local = await orderLocalDatasource.updateOrder(OrderModel.fromEntity(order));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderRepositoryImpl',
          method: 'updateOrder',
          param: jsonEncode(OrderModel.fromEntity(order).toJson()),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
