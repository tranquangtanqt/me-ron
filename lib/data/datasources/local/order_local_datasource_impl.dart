import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../domain/usecases/params/report_order_params.dart';
import '../../../domain/usecases/params/report_product_params.dart';
import '../../models/order_model.dart';
import '../../models/order_item_model.dart';
import '../../models/order_status_summary_model.dart';
import '../../models/product_summary_model.dart';
import '../interfaces/order_datasource.dart';
import '../../../domain/usecases/params/order_params.dart';
import '../../../core/enums/order_status.dart';

class OrderLocalDatasourceImpl extends OrderDatasource {
  final DatabaseService _databaseService;

  OrderLocalDatasourceImpl(this._databaseService);

  String _buildOrderWhere(OrderParams params, List<dynamic> args) {
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

    if (params.status != null && params.status != -1) {
      if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
      sqlWhere += 'status = ?';
      args.add(params.status);
    }

    if (params.userId != null) {
      if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
      sqlWhere += 'userId = ?';
      args.add(params.userId);
    }

    return sqlWhere;
  }

  String _buildReportOrderWhere(ReportOrderParams params, List<dynamic> args) {
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

    if (params.status != null && params.status != -1) {
      if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
      sqlWhere += 'status = ?';
      args.add(params.status);
    }

    if (params.userId != null) {
      if (sqlWhere.isNotEmpty) sqlWhere += ' AND ';
      sqlWhere += 'userId = ?';
      args.add(params.userId);
    }

    return sqlWhere;
  }

  @override
  Future<Result<List<OrderModel>>> getAllOrders(OrderParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildOrderWhere(params, args);

      String innerSql = 'SELECT * FROM ${DatabaseConfig.orderTableName}';
      if (sqlWhere.isNotEmpty) innerSql += ' WHERE $sqlWhere';
      innerSql += ' ORDER BY deliveryDatetime DESC LIMIT ? OFFSET ?';
      args.add(params.base.limit);
      args.add(params.base.offset ?? 0);

      String sql =
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
          FROM ($innerSql) AS O
            LEFT JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
          ORDER BY O.deliveryDatetime DESC
        ''';
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
  Future<Result<int>> getOrdersCount(OrderParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildOrderWhere(params, args);

      String sql = 'SELECT COUNT(*) AS cnt FROM ${DatabaseConfig.orderTableName}';
      if (sqlWhere.isNotEmpty) sql += ' WHERE $sqlWhere';

      var res = await _databaseService.database.rawQuery(sql, args);

      return Result.success(data: Sqflite.firstIntValue(res) ?? 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  String _buildReportProductOrderWhere(ReportProductParams params, List<dynamic> args) {
    final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
    String sqlWhere = 'OO.status <> ${OrderStatus.cancelled.value}';

    if (params.fromDate != null) {
      sqlWhere += ' AND OO.deliveryDatetime >= ?';
      args.add(format.format(params.fromDate!));
    }

    if (params.toDate != null) {
      sqlWhere += ' AND OO.deliveryDatetime <= ?';
      args.add(format.format(params.toDate!));
    }

    if (params.productId != null) {
      sqlWhere +=
          ' AND EXISTS (SELECT 1 FROM ${DatabaseConfig.orderItemTableName} AS D2 '
          'WHERE D2.orderId = OO.id AND D2.productId = ?)';
      args.add(params.productId);
    }

    return sqlWhere;
  }

  @override
  Future<Result<List<OrderModel>>> getAllOrderReportProduct(ReportProductParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildReportProductOrderWhere(params, args);

      final innerSql =
          'SELECT * FROM ${DatabaseConfig.orderTableName} AS OO '
          'WHERE $sqlWhere ORDER BY OO.deliveryDatetime DESC LIMIT ? OFFSET ?';
      args.add(params.base.limit);
      args.add(params.base.offset ?? 0);

      String joinOn = 'O.id = D.orderId';
      if (params.productId != null) {
        joinOn += ' AND D.productId = ?';
      }

      String sql =
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
          FROM ($innerSql) AS O
            LEFT JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON $joinOn
          ORDER BY O.deliveryDatetime DESC
        ''';

      final joinArgs = [...args];
      if (params.productId != null) joinArgs.add(params.productId);

      print(sql);

      var res = await _databaseService.database.rawQuery(sql, joinArgs);
      print(joinArgs);

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
  Future<Result<int>> getOrdersCountReportProduct(ReportProductParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildReportProductOrderWhere(params, args);

      final sql = 'SELECT COUNT(*) AS cnt FROM ${DatabaseConfig.orderTableName} AS OO WHERE $sqlWhere';

      var res = await _databaseService.database.rawQuery(sql, args);

      return Result.success(data: Sqflite.firstIntValue(res) ?? 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductSummaryModel>>> getProductSummaryReportProduct(ReportProductParams params) async {
    try {
      List<dynamic> args = [];

      final format = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS");
      String sqlWhere = 'O.status <> ${OrderStatus.cancelled.value}';

      if (params.fromDate != null) {
        sqlWhere += ' AND O.deliveryDatetime >= ?';
        args.add(format.format(params.fromDate!));
      }

      if (params.toDate != null) {
        sqlWhere += ' AND O.deliveryDatetime <= ?';
        args.add(format.format(params.toDate!));
      }

      if (params.productId != null) {
        sqlWhere += ' AND D.productId = ?';
        args.add(params.productId);
      }

      String sql =
          '''
          SELECT D.productId AS productId, MIN(D.snapshotName) AS productName, SUM(D.quantity) AS quantity
          FROM ${DatabaseConfig.orderTableName} AS O
            INNER JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
          WHERE $sqlWhere
          GROUP BY D.productId
        ''';

      var res = await _databaseService.database.rawQuery(sql, args);

      return Result.success(
        data: res.map((e) => ProductSummaryModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderModel>>> getAllOrderReportOrder(ReportOrderParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildReportOrderWhere(params, args);

      String innerSql = 'SELECT * FROM ${DatabaseConfig.orderTableName}';
      if (sqlWhere.isNotEmpty) innerSql += ' WHERE $sqlWhere';
      innerSql += ' ORDER BY deliveryDatetime DESC LIMIT ? OFFSET ?';
      args.add(params.base.limit);
      args.add(params.base.offset ?? 0);

      String sql =
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
          FROM ($innerSql) AS O
            LEFT JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
            LEFT JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
          ORDER BY O.deliveryDatetime DESC
        ''';
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
  Future<Result<int>> getOrdersCountReportOrder(ReportOrderParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildReportOrderWhere(params, args);

      String sql = 'SELECT COUNT(*) AS cnt FROM ${DatabaseConfig.orderTableName}';
      if (sqlWhere.isNotEmpty) sql += ' WHERE $sqlWhere';

      var res = await _databaseService.database.rawQuery(sql, args);

      return Result.success(data: Sqflite.firstIntValue(res) ?? 0);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<OrderStatusSummaryModel>>> getOrderStatusSummary(ReportOrderParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildReportOrderWhere(params, args);

      String sql = 'SELECT status, COUNT(*) AS cnt, SUM(total) AS amt FROM ${DatabaseConfig.orderTableName}';
      if (sqlWhere.isNotEmpty) sql += ' WHERE $sqlWhere';
      sql += ' GROUP BY status';

      var res = await _databaseService.database.rawQuery(sql, args);

      return Result.success(
        data: res.map((e) => OrderStatusSummaryModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<ProductSummaryModel>>> getOrderProductSummary(ReportOrderParams params) async {
    try {
      List<dynamic> args = [];
      final sqlWhere = _buildReportOrderWhere(params, args);

      final finalWhere = sqlWhere.isNotEmpty
          ? '$sqlWhere AND O.status <> ${OrderStatus.cancelled.value}'
          : 'O.status <> ${OrderStatus.cancelled.value}';

      String sql =
          '''
          SELECT D.productId AS productId, MIN(D.snapshotName) AS productName, SUM(D.quantity) AS quantity
          FROM ${DatabaseConfig.orderTableName} AS O
            INNER JOIN ${DatabaseConfig.orderItemTableName} AS D
              ON O.id = D.orderId
          WHERE $finalWhere
          GROUP BY D.productId
        ''';

      var res = await _databaseService.database.rawQuery(sql, args);

      return Result.success(
        data: res.map((e) => ProductSummaryModel.fromJson(e)).toList(),
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
