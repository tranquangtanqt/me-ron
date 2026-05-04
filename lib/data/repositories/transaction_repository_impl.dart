import 'dart:convert';

import '../../core/common/result.dart';
import '../../core/constants/constants.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/transaction_local_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl extends TransactionRepository {
  final TransactionLocalDatasourceImpl transactionLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  TransactionRepositoryImpl({
    required this.transactionLocalDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<int>> syncAllUserTransactions(String userId) async {
    try {
      return Result.success(data: 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<TransactionEntity>>> getUserTransactions(
    String userId, {
    String orderBy = 'createdAt',
    String sortBy = 'DESC',
    int limit = 10,
    int? offset,
    String? contains,
  }) async {
    try {
      var local = await transactionLocalDatasource.getUserTransactions(
        userId,
        orderBy: orderBy,
        sortBy: sortBy,
        limit: limit,
        offset: offset,
        contains: contains,
      );

      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data!.map((e) => e.toEntity()).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<TransactionEntity?>> getTransaction(int transactionId) async {
    try {
      var local = await transactionLocalDatasource.getTransaction(transactionId);
      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      var local = await transactionLocalDatasource.createTransaction(data);
      if (local.isFailure) return Result.failure(error: local.error!);


      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'TransactionRepositoryImpl',
          method: 'createTransaction',
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
  Future<Result<void>> deleteTransaction(int transactionId) async {
    try {
      final local = await transactionLocalDatasource.deleteTransaction(transactionId);
      if (local.isFailure) return Result.failure(error: local.error!);


      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'TransactionRepositoryImpl',
          method: 'deleteTransaction',
          param: transactionId.toString(),
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
  Future<Result<void>> updateTransaction(TransactionEntity transaction) async {
    try {
      var data = TransactionModel.fromEntity(transaction);

      final local = await transactionLocalDatasource.updateTransaction(data);
      if (local.isFailure) return Result.failure(error: local.error!);


      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'TransactionRepositoryImpl',
          method: 'updateTransaction',
          param: jsonEncode(data.toJson()),
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
