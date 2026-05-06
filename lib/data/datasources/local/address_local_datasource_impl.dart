import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/address_model.dart';
import '../interfaces/address_datasource.dart';

class AddressLocalDatasourceImpl extends AddressDatasource {
  final DatabaseService _databaseService;

  AddressLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<AddressModel>>> getAllAddress() async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.addressTableName,
      );

      final data = res
          .map((e) => AddressModel.fromJson(e))
          .toList();

      return Result.success(data: data);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<AddressModel?>> getAddress(String code) async {
      try {
        var res = await _databaseService.database.query(
          DatabaseConfig.addressTableName,
          where: 'code = ?',
          whereArgs: [code],
        );

        if (res.isEmpty) return Result.success(data: null);

        return Result.success(data: AddressModel.fromJson(res.first));
      } catch (e) {
        return Result.failure(error: e);
      }
  }

  @override
  Future<Result<String>> createAddress(AddressModel address) async {
    try {
      await _databaseService.database.insert(
        DatabaseConfig.addressTableName,
        address.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: address.code);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateAddress(AddressModel address) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.addressTableName,
        address.toJson(),
        where: 'code = ?',
        whereArgs: [address.code],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteAddress(String code) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.addressTableName,
        where: 'code = ?',
        whereArgs: [code],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
