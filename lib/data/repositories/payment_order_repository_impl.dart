import 'dart:convert';

import '../../core/common/result.dart';
import '../../domain/entities/payment_order_entity.dart';
import '../../domain/repositories/payment_order_repository.dart';
import '../datasources/local/payment_order_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/payment_order_model.dart';
import '../models/queued_action_model.dart';

class PaymentOrderRepositoryImpl extends PaymentOrderRepository {
  final PaymentOrderLocalDatasourceImpl paymentOrderLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  PaymentOrderRepositoryImpl({
    required this.paymentOrderLocalDatasource,
    required this.queuedActionLocalDatasource,
  });


  // @override
  // Future<Result<List<PaymentOrderModel>>> getAllPaymentOrders(PaymentOrderParams params) async {
  //   try {
  //     final local = await orderLocalDatasource.getAllPaymentOrders(params);
  //
  //     if (local.isFailure) return Result.failure(error: local.error!);
  //
  //     final list = local.data ?? [];
  //     // return Result.success(data: list.map((e) => e.toEntity()).toList());
  //     return Result.success(data: list.toList());
  //   } catch (e) {
  //     return Result.failure(error: e);
  //   }
  // }

  @override
  Future<Result<List<PaymentOrderModel>>> getPaymentOrder(int orderId) async {
    try {
      final local = await paymentOrderLocalDatasource.getPaymentOrder(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPaymentOrder(PaymentOrderEntity order) async {
    try {
      final data = PaymentOrderModel.fromEntity(order);

      final local = await paymentOrderLocalDatasource.createPaymentOrder(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PaymentOrderRepositoryImpl',
          method: 'createPaymentOrder',
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
  Future<Result<void>> deletePaymentOrder(int orderId) async {
    try {
      final local = await paymentOrderLocalDatasource.deletePaymentOrder(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PaymentOrderRepositoryImpl',
          method: 'deletePaymentOrder',
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
  Future<Result<void>> updatePaymentOrder(PaymentOrderEntity order) async {
    try {
      final local = await paymentOrderLocalDatasource.updatePaymentOrder(PaymentOrderModel.fromEntity(order));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PaymentOrderRepositoryImpl',
          method: 'updatePaymentOrder',
          param: jsonEncode(PaymentOrderModel.fromEntity(order).toJson()),
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
