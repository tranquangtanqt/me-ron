import 'dart:convert';

import '../../core/common/result.dart';
import '../../domain/entities/purchase_entity.dart';
import '../../domain/entities/purchase_item_entity.dart';
import '../../domain/repositories/purchase_repository.dart';
import '../../domain/usecases/params/purchase_params.dart';
import '../datasources/local/purchase_local_datasource_impl.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../models/purchase_item_model.dart';
import '../models/purchase_model.dart';
import '../models/queued_action_model.dart';

class PurchaseRepositoryImpl extends PurchaseRepository {
  final PurchaseLocalDatasourceImpl purchaseLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  PurchaseRepositoryImpl({
    required this.purchaseLocalDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<List<PurchaseModel>>> getAllPurchases(PurchaseParams params) async {
    try {
      final local = await purchaseLocalDatasource.getAllPurchases(params);
      if (local.isFailure) return Result.failure(error: local.error!);

      final list = local.data ?? [];
      return Result.success(data: list.toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<PurchaseModel?>> getPurchase(int purchaseId) async {
    try {
      final local = await purchaseLocalDatasource.getPurchase(purchaseId);
      if (local.isFailure) return Result.failure(error: local.error!);

      return Result.success(data: local.data);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPurchase(PurchaseEntity purchase) async {
    try {
      final data = PurchaseModel.fromEntity(purchase);

      final local = await purchaseLocalDatasource.createPurchase(data);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseRepositoryImpl',
          method: 'createPurchase',
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
  Future<Result<int>> createPurchaseWithItems(PurchaseEntity purchase, List<dynamic> items) async {
    try {
      final data = PurchaseModel.fromEntity(purchase);

      final itemsModels = items.map((dynamic it) => PurchaseItemModel.fromEntity(it as PurchaseItemEntity)).toList();

      final local = await purchaseLocalDatasource.createPurchaseWithItems(data, itemsModels);
      if (local.isFailure) return Result.failure(error: local.error!);

      final createdPurchaseId = local.data!;

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseRepositoryImpl',
          method: 'createPurchaseWithItems',
          param: jsonEncode({
            'purchase': data.toJson(),
            'items': itemsModels.map((e) => e.toJson()).toList(),
          }),
          isCritical: true,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: createdPurchaseId);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updatePurchase(PurchaseEntity purchase) async {
    try {
      final local = await purchaseLocalDatasource.updatePurchase(PurchaseModel.fromEntity(purchase));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseRepositoryImpl',
          method: 'updatePurchase',
          param: jsonEncode(PurchaseModel.fromEntity(purchase).toJson()),
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
  Future<Result<void>> updatePurchaseWithItems(PurchaseEntity purchase, List<dynamic> items) async {
    try {
      final data = PurchaseModel.fromEntity(purchase);
      final itemsModels = items.map((dynamic it) => PurchaseItemModel.fromEntity(it as PurchaseItemEntity)).toList();

      final local = await purchaseLocalDatasource.updatePurchaseWithItems(data, itemsModels);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseRepositoryImpl',
          method: 'updatePurchaseWithItems',
          param: jsonEncode({
            'purchase': data.toJson(),
            'items': itemsModels.map((e) => e.toJson()).toList(),
          }),
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
  Future<Result<void>> deletePurchase(int purchaseId) async {
    try {
      final local = await purchaseLocalDatasource.deletePurchase(purchaseId);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecond,
          repository: 'PurchaseRepositoryImpl',
          method: 'deletePurchase',
          param: purchaseId.toString(),
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
