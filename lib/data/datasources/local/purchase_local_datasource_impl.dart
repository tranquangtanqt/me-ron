import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../domain/usecases/params/purchase_params.dart';
import '../../models/purchase_item_model.dart';
import '../../models/purchase_model.dart';
import '../interfaces/purchase_datasource.dart';

class PurchaseLocalDatasourceImpl extends PurchaseDatasource {
  final DatabaseService _databaseService;

  PurchaseLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<PurchaseModel>>> getAllPurchases(PurchaseParams params) async {
    try {
      String sql =
          '''
          SELECT
            P.*,
            I.id AS purchaseItemId,
            I.name AS itemName,
            I.price AS itemPrice
          FROM ${DatabaseConfig.purchaseTableName} AS P
            LEFT JOIN ${DatabaseConfig.purchaseItemTableName} AS I
              ON P.id = I.purchaseId
        ''';

      List<dynamic> args = [];
      String sqlWhere = '';

      if (params.fromDate != null) {
        sqlWhere += 'P.date >= ?';
        args.add(params.fromDate!.toIso8601String());
      }

      if (params.toDate != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'P.date <= ?';
        args.add(params.toDate!.toIso8601String());
      }

      if (sqlWhere.isNotEmpty) {
        sql += ' WHERE $sqlWhere';
      }

      sql += ' ORDER BY P.date DESC';

      var res = await _databaseService.database.rawQuery(sql, args);

      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(data: res.map((e) => PurchaseModel.fromJson(e)).toList());
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<PurchaseModel?>> getPurchase(int id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.purchaseTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: PurchaseModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPurchase(PurchaseModel purchase) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.purchaseTableName,
        purchase.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createPurchaseWithItems(PurchaseModel purchase, List<PurchaseItemModel> items) async {
    try {
      final createdId = await _databaseService.database.transaction((trx) async {
        final id = await trx.insert(
          DatabaseConfig.purchaseTableName,
          purchase.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        if (items.isNotEmpty) {
          final batch = trx.batch();
          for (var item in items) {
            item.purchaseId = id;
            batch.insert(
              DatabaseConfig.purchaseItemTableName,
              item.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          await batch.commit(noResult: true);
        }

        return id;
      });

      return Result.success(data: createdId);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updatePurchase(PurchaseModel purchase) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.purchaseTableName,
        purchase.toJson(),
        where: 'id = ?',
        whereArgs: [purchase.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updatePurchaseWithItems(PurchaseModel purchase, List<PurchaseItemModel> items) async {
    try {
      if (purchase.id == null) {
        return Result.failure(error: 'Purchase id is null');
      }

      await _databaseService.database.transaction((trx) async {
        await trx.update(
          DatabaseConfig.purchaseTableName,
          purchase.toJson(),
          where: 'id = ?',
          whereArgs: [purchase.id],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await trx.delete(
          DatabaseConfig.purchaseItemTableName,
          where: 'purchaseId = ?',
          whereArgs: [purchase.id],
        );

        if (items.isNotEmpty) {
          final batch = trx.batch();
          for (var item in items) {
            item.purchaseId = purchase.id;
            batch.insert(
              DatabaseConfig.purchaseItemTableName,
              item.toJson(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

          await batch.commit(noResult: true);
        }
      });

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deletePurchase(int id) async {
    try {
      await _databaseService.database.transaction((trx) async {
        await trx.delete(
          DatabaseConfig.purchaseItemTableName,
          where: 'purchaseId = ?',
          whereArgs: [id],
        );

        await trx.delete(
          DatabaseConfig.purchaseTableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      });

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
