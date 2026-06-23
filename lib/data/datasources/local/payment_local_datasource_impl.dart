import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/payment_model.dart';
import '../interfaces/payment_datasource.dart';

class PaymentLocalDatasourceImpl extends PaymentDatasource {
  final DatabaseService _databaseService;

  PaymentLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<int>> createPayment(PaymentModel payment) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.paymentTableName,
        payment.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // The id has been generated in models
      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updatePayment(PaymentModel payment) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.paymentTableName,
        payment.toJson(),
        where: 'id = ?',
        whereArgs: [payment.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deletePayment(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.paymentTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<List<PaymentModel>>> getPayment(int id) async {
    try {
      // var res = await _databaseService.database.query(
      //   DatabaseConfig.paymentTableName,
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
        data: res.map((e) => PaymentModel.fromJson(e)).toList(),
      );

    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
