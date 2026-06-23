import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/payment_order_model.dart';
import '../interfaces/payment_order_datasource.dart';

class PaymentOrderLocalDatasourceImpl extends PaymentOrderDatasource {
  final DatabaseService _databaseService;

  PaymentOrderLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<int>> createPaymentOrder(PaymentOrderModel paymentOrder) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.paymentTableName,
        paymentOrder.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updatePaymentOrder(PaymentOrderModel paymentOrder) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.paymentTableName,
        paymentOrder.toJson(),
        where: 'id = ?',
        whereArgs: [paymentOrder.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deletePaymentOrder(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.paymentOrderTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<PaymentOrderModel>>> getPaymentOrder(int id) async {
    try {
      // var res = await _databaseService.database.query(
      //   DatabaseConfig.paymentOrderTableName,
      //   where: 'id = ?',
      //   whereArgs: [id],
      // );

      var res = await _databaseService.database.rawQuery(
        '''
          SELECT 
            O.*, 
            U.name AS userName,
            D.id AS paymentItemId,
            D.paymentId AS paymentId,
            D.productId AS productId,
            D.snapshotName As snapshotName,
            D.snapshotPrice As snapshotPrice,
            D.quantity As quantity,
            D.lineTotal As lineTotal
          FROM ${DatabaseConfig.paymentTableName} AS O
            INNER JOIN ${DatabaseConfig.userTableName} AS U
              ON O.userId = U.id
          WHERE O.id = ?
          ''',
          [id],
      );

      return res.isEmpty
          ? Result.success(data: [])
          : Result.success(
        data: res.map((e) => PaymentOrderModel.fromJson(e)).toList(),
      );

    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
