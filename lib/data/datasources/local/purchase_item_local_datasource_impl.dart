import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../models/purchase_item_model.dart';
import '../interfaces/purchase_item_datasource.dart';

class PurchaseItemLocalDatasourceImpl extends PurchaseItemDatasource {
  final DatabaseService _databaseService;

  PurchaseItemLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<PurchaseItemModel>>> getAllPurchaseItems(BaseParams params) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.purchaseItemTableName,
        orderBy: '${params.orderBy} ${params.sortBy}',
        limit: params.limit,
        offset: params.offset ?? 0,
      );

      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(data: res.map((e) => PurchaseItemModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<PurchaseItemModel>>> getPurchaseItemsByPurchaseId(int purchaseId) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.purchaseItemTableName,
        where: 'purchaseId = ?',
        whereArgs: [purchaseId],
      );

      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(data: res.map((e) => PurchaseItemModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPurchaseItem(PurchaseItemModel purchaseItem) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.purchaseItemTableName,
        purchaseItem.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updatePurchaseItem(PurchaseItemModel purchaseItem) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.purchaseItemTableName,
        purchaseItem.toJson(),
        where: 'id = ?',
        whereArgs: [purchaseItem.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deletePurchaseItem(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.purchaseItemTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<PurchaseItemModel?>> getPurchaseItem(int id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.purchaseItemTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: PurchaseItemModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
