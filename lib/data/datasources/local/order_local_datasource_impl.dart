import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';
import '../interfaces/order_datasource.dart';

class OrderLocalDatasourceImpl extends OrderDatasource {
  final DatabaseService _databaseService;

  OrderLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<OrderModel>>> getAllOrders(
      {
        String orderBy = 'createdAt',
        String sortBy = 'DESC',
        int limit = 10,
        int? offset,
        String? contains,
      }) async {
    try {
      var res = await _databaseService.database.rawQuery(
        '''
          SELECT 
            O.*, 
            U.name AS userName,
            D.orderId AS orderId,
            D.productId AS productId,
            D.snapshotName As snapshotName,
            D.snapshotPrice As snapshotPrice,
            D.quantity As quantity,
            D.lineTotal As lineTotal
          FROM ${DatabaseConfig.orderTableName} AS O
            INNER JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
          ORDER BY createdAt DESC
          LIMIT ?
          OFFSET ?
          ''',
            [
              limit,
              offset ?? 0,
            ],
      );
      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(
        data: res.map((e) => OrderModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createOrder(OrderModel order) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.orderTableName,
        order.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateOrder(OrderModel order) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.orderTableName,
        order.toJson(),
        where: 'id = ?',
        whereArgs: [order.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteOrder(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.orderTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderModel>>> getOrder(int id) async {
    try {
      // var res = await _databaseService.database.query(
      //   DatabaseConfig.orderTableName,
      //   where: 'id = ?',
      //   whereArgs: [id],
      // );

      var res = await _databaseService.database.rawQuery(
        '''
          SELECT 
            O.*, 
            U.name AS userName,
            D.orderId AS orderId,
            D.productId AS productId,
            D.snapshotName As snapshotName,
            D.snapshotPrice As snapshotPrice,
            D.quantity As quantity,
            D.lineTotal As lineTotal
          FROM ${DatabaseConfig.orderTableName} AS O
            INNER JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
          WHERE O.id = ?
          ''',
          [id],
      );

      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(
        data: res.map((e) => OrderModel.fromJson(e)).toList(),
      );

    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
