import 'dart:convert';

import 'package:me_ron/domain/usecases/params/base_params.dart';

import '../../core/common/result.dart';
import '../../domain/entities/order_item_entity.dart';
import '../../domain/repositories/order_item_repository.dart';
import '../datasources/local/order_item_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/order_item_model.dart';
import '../models/queued_action_model.dart';

class OrderItemRepositoryImpl extends OrderItemRepository {
  final OrderItemLocalDatasourceImpl orderItemLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  OrderItemRepositoryImpl({
    required this.orderItemLocalDatasource,
    required this.queuedActionLocalDatasource,
  });


  @override
  Future<Result<List<OrderItemModel>>> getAllOrderItems(BaseParams params) async {
    try {
      final local = await orderItemLocalDatasource.getAllOrderItems(params);

      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      // return Result.success(data: list.map((e) => e.toEntity()).toList());
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<OrderItemEntity?>> getOrderItem(int orderId) async {
    try {
      final local = await orderItemLocalDatasource.getOrderItem(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createOrderItem(OrderItemEntity order) async {
    try {
      final data = OrderItemModel.fromEntity(order);

      final local = await orderItemLocalDatasource.createOrderItem(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderItemRepositoryImpl',
          method: 'createOrderItem',
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
  Future<Result<void>> deleteOrderItem(int orderId) async {
    try {
      final local = await orderItemLocalDatasource.deleteOrderItem(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderItemRepositoryImpl',
          method: 'deleteOrderItem',
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
  Future<Result<void>> updateOrderItem(OrderItemEntity order) async {
    try {
      final local = await orderItemLocalDatasource.updateOrderItem(OrderItemModel.fromEntity(order));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'OrderItemRepositoryImpl',
          method: 'updateOrderItem',
          param: jsonEncode(OrderItemModel.fromEntity(order).toJson()),
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
