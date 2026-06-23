import 'dart:convert';

import '../../core/common/result.dart';
import '../../domain/entities/payment_entity.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/local/payment_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/payment_model.dart';
import '../models/queued_action_model.dart';

class PaymentRepositoryImpl extends PaymentRepository {
  final PaymentLocalDatasourceImpl paymentLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  PaymentRepositoryImpl({
    required this.paymentLocalDatasource,
    required this.queuedActionLocalDatasource,
  });


  // @override
  // Future<Result<List<PaymentModel>>> getAllPayments(PaymentParams params) async {
  //   try {
  //     final local = await paymentLocalDatasource.getAllPayments(params);
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
  Future<Result<List<PaymentModel>>> getPayment(int orderId) async {
    try {
      final local = await paymentLocalDatasource.getPayment(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPayment(PaymentEntity order) async {
    try {
      final data = PaymentModel.fromEntity(order);

      final local = await paymentLocalDatasource.createPayment(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PaymentRepositoryImpl',
          method: 'createPayment',
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
  Future<Result<void>> deletePayment(int orderId) async {
    try {
      final local = await paymentLocalDatasource.deletePayment(orderId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PaymentRepositoryImpl',
          method: 'deletePayment',
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
  Future<Result<void>> updatePayment(PaymentEntity order) async {
    try {
      final local = await paymentLocalDatasource.updatePayment(PaymentModel.fromEntity(order));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PaymentRepositoryImpl',
          method: 'updatePayment',
          param: jsonEncode(PaymentModel.fromEntity(order).toJson()),
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
