import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../models/order_item_model.dart';
import '../interfaces/order_item_datasource.dart';

class OrderItemLocalDatasourceImpl extends OrderItemDatasource {
  final DatabaseService _databaseService;

  OrderItemLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<OrderItemModel>>> getAllOrderItems(BaseParams params) async {
    try {
      var res = await _databaseService.database.rawQuery(
        '''
          SELECT O.*, U.name AS userName
          FROM ${DatabaseConfig.orderTableName} AS O
            INNER JOIN ${DatabaseConfig.userTableName} AS U
            ON O.userId = U.id
          ORDER BY $params.orderBy $params.sortBy
          LIMIT ?
          OFFSET ?
          ''',
            [
              params.limit,
              params.offset ?? 0,
            ],
      );
      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(
        data: res.map((e) => OrderItemModel.fromJson(e)).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createOrderItem(OrderItemModel orderItem) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.orderItemTableName,
        orderItem.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateOrderItem(OrderItemModel orderItem) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.orderItemTableName,
        orderItem.toJson(),
        where: 'id = ?',
        whereArgs: [orderItem.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteOrderItem(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.orderItemTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<OrderItemModel?>> getOrderItem(int id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.orderTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: OrderItemModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
