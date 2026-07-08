import 'dart:convert';

import '../../core/common/result.dart';
import '../../domain/entities/purchase_item_entity.dart';
import '../../domain/repositories/purchase_item_repository.dart';
import '../../domain/usecases/params/base_params.dart';
import '../datasources/local/purchase_item_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/purchase_item_model.dart';
import '../models/queued_action_model.dart';

class PurchaseItemRepositoryImpl extends PurchaseItemRepository {
  final PurchaseItemLocalDatasourceImpl purchaseItemLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  PurchaseItemRepositoryImpl({
    required this.purchaseItemLocalDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<List<PurchaseItemModel>>> getAllPurchaseItems(BaseParams params) async {
    try {
      final local = await purchaseItemLocalDatasource.getAllPurchaseItems(params);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<PurchaseItemModel>>> getPurchaseItemsByPurchaseId(int purchaseId) async {
    try {
      final local = await purchaseItemLocalDatasource.getPurchaseItemsByPurchaseId(purchaseId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<PurchaseItemEntity?>> getPurchaseItem(int purchaseItemId) async {
    try {
      final local = await purchaseItemLocalDatasource.getPurchaseItem(purchaseItemId);
      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data?.toEntity());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPurchaseItem(PurchaseItemEntity purchaseItem) async {
    try {
      final data = PurchaseItemModel.fromEntity(purchaseItem);

      final local = await purchaseItemLocalDatasource.createPurchaseItem(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseItemRepositoryImpl',
          method: 'createPurchaseItem',
          param: jsonEncode(data.toJson()),
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
  Future<Result<void>> updatePurchaseItem(PurchaseItemEntity purchaseItem) async {
    try {
      final local = await purchaseItemLocalDatasource.updatePurchaseItem(PurchaseItemModel.fromEntity(purchaseItem));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseItemRepositoryImpl',
          method: 'updatePurchaseItem',
          param: jsonEncode(PurchaseItemModel.fromEntity(purchaseItem).toJson()),
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
  Future<Result<void>> deletePurchaseItem(int purchaseItemId) async {
    try {
      final local = await purchaseItemLocalDatasource.deletePurchaseItem(purchaseItemId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseItemRepositoryImpl',
          method: 'deletePurchaseItem',
          param: purchaseItemId.toString(),
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
