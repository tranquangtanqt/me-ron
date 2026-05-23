import 'package:sqflite/sqflite.dart';

import '../../../core/common/result.dart';
import '../../../core/services/database/database_config.dart';
import '../../../core/services/database/database_service.dart';
import '../../models/category_model.dart';
import '../interfaces/category_datasource.dart';

class CategoryLocalDatasourceImpl extends CategoryDatasource {
  final DatabaseService _databaseService;

  CategoryLocalDatasourceImpl(this._databaseService);

  @override
  Future<Result<List<CategoryModel>>> getAllCategory() async {
    try {
      var res = await _databaseService.database.query(
        DatabaseConfig.categoriesTableName,
      );

      final data = res
          .map((e) => CategoryModel.fromJson(e))
          .toList();

      return Result.success(data: data);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<CategoryModel?>> getCategory(int id) async {
      try {
        var res = await _databaseService.database.query(
          DatabaseConfig.categoriesTableName,
          where: 'id = ?',
          whereArgs: [id],
        );

        if (res.isEmpty) return Result.success(data: null);

        return Result.success(data: CategoryModel.fromJson(res.first));
      } catch (e) {
        return Result.failure(error: e);
      }
  }

  @override
  Future<Result<int>> createCategory(CategoryModel category) async {
    try {
      final id = await _databaseService.database.insert(
        DatabaseConfig.categoriesTableName,
        category.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: id);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateCategory(CategoryModel category) async {
    try {
      await _databaseService.database.update(
        DatabaseConfig.categoriesTableName,
        category.toJson(),
        where: 'id = ?',
        whereArgs: [category.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteCategory(int id) async {
    try {
      await _databaseService.database.delete(
        DatabaseConfig.categoriesTableName,
        where: 'id = ?',
        whereArgs: [id],
      );

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
