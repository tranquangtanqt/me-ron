import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/user_model.dart';
import '../interfaces/user_datasource.dart';

class UserLocalDatasourceImpl extends UserDatasource {
  final DatabaseService _databaseService;

  UserLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<UserModel>>> getAllUser() async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.userTableName,
      );

      final data = res
          .map((e) => UserModel.fromJson(e))
          .toList();

      return Result.success(data: data);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<UserModel?>> getUser(int id) async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (res.isEmpty) return Result.success(data: null);

      return Result.success(data: UserModel.fromJson(res.first));
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<int>> createUser(UserModel user) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.userTableName,
        user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateUser(UserModel user) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.userTableName,
        user.toJson(),
        where: 'id = ?',
        whereArgs: [user.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteUser(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.userTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
