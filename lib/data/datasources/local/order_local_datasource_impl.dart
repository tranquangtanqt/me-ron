import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../models/order_model.dart';
import '../interfaces/order_datasource.dart';

class OrderLocalDatasourceImpl extends OrderDatasource {
  final DatabaseService _databaseService;

  OrderLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<OrderModel>>> getAllOrders(BaseParams params) async {
    try {
      String sql = '''
          SELECT 
            O.*, 
            U.name AS userName,
            D.id AS orderItemId,
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
          
        ''';

      List<dynamic> args = [];

      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
      String sqlWhere = '';

      if (params.startDate != null) {
        sqlWhere += 'deliveryDatetime >= ?';
        args.add(format.format(params.startDate!));
      }

      if (params.endDate != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'deliveryDatetime <= ?';
        args.add(format.format(params.endDate!));
      }

      if (params.status != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'status = ?';
        args.add(params.status);
      }

      if (sqlWhere.isNotEmpty) {
        sql += ' WHERE $sqlWhere';
      }

      sql += ' ORDER BY deliveryDatetime DESC';

      var res = await _databaseService.database.rawQuery(sql, args);

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
            D.id AS orderItemId,
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
