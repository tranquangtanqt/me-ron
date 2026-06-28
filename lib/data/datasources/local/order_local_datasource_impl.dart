import 'package:intl/intl.dart';
import 'package:me_ron/core/enums/order_status.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../domain/usecases/params/report_product_params.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../interfaces/order_datasource.dart';
import '../../../domain/usecases/params/order_params.dart';

class OrderLocalDatasourceImpl extends OrderDatasource {
  final DatabaseService _databaseService;

  OrderLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params) async {
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
            LEFT JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
        ''';

      List<dynamic> args = [];

      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
      String sqlWhere = '';

      if (params.fromDate != null) {
        sqlWhere += 'deliveryDatetime >= ?';
        args.add(format.format(params.fromDate!));
      }

      if (params.toDate != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'deliveryDatetime <= ?';
        args.add(format.format(params.toDate!));
      }

      if (params.status != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'status = ?';
        args.add(params.status);
      }

      if (params.userId != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'userId = ?';
        args.add(params.userId);
      }

      if (sqlWhere.isNotEmpty) {
        sql += ' WHERE $sqlWhere';
      }

      sql += ' ORDER BY deliveryDatetime DESC';
      print(sql);

      var res = await _databaseService.database.rawQuery(sql, args);
      print(args);

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
  Future<Result<List<OrderModel>>> getAllOrderReportProduct(ReportProductParams params) async {
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
            LEFT JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
        ''';

      List<dynamic> args = [];

      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
      String sqlWhere = '';

      if (params.fromDate != null) {
        sqlWhere += 'deliveryDatetime >= ?';
        args.add(format.format(params.fromDate!));
      }

      if (params.toDate != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'deliveryDatetime <= ?';
        args.add(format.format(params.toDate!));
      }

      if (params.productId != null) {
        if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
        sqlWhere += 'D.productId = ?';
        args.add(params.productId);
      }

      if (sqlWhere.isNotEmpty) {
        sql += ' WHERE status <> ${OrderStatus.cancelled.value}'; //TODO status
        sql += ' AND $sqlWhere'; //TODO status
      } else {
        sql += ' WHERE status <> ${OrderStatus.cancelled.value}'; //TODO status
      }

      sql += ' ORDER BY deliveryDatetime DESC';
      print(sql);

      var res = await _databaseService.database.rawQuery(sql, args);
      print(args);

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
  Future<Result<int>> createOrderWithItems(OrderModel order, List<OrderItemModel> items) async {
    try {
      final createdId = await _databaseService.database.transaction((trx) async {
        final id = await trx.insert(
          DatabaseConfig.orderTableName,
          order.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        if (items.isNotEmpty) {
          final batch = trx.batch();
          for (var item in items) {
            item.orderId = id;
            batch.insert(
              DatabaseConfig.orderItemTableName,
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
  Future<Result<void>> updateOrderWithItems(OrderModel order, List<OrderItemModel> items) async {
    try {
      if (order.id == null) {
        return Result.failure(error: 'Order id is null');
      }

      await _databaseService.database.transaction((trx) async {
        await trx.update(
          DatabaseConfig.orderTableName,
          order.toJson(),
          where: 'id = ?',
          whereArgs: [order.id],
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await trx.delete(
          DatabaseConfig.orderItemTableName,
          where: 'orderId = ?',
          whereArgs: [order.id],
        );

        if (items.isNotEmpty) {
          final batch = trx.batch();
          for (var item in items) {
            item.orderId = order.id;
            batch.insert(
              DatabaseConfig.orderItemTableName,
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

  @override
  Future<Result<void>> updateStatusOrder(int id, int status) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.orderTableName,
        {
          'status': status,
        },
        where: 'id = ?',
        whereArgs: [id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
