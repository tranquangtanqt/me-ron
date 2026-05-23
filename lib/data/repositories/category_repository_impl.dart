import 'dart:convert';

import '../../core/common/result.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/queued_action_local_datasource_impl.dart';
import '../datasources/local/category_local_datasource_impl.dart';
import '../models/queued_action_model.dart';
import '../models/category_model.dart';

class CategoryRepositoryImpl extends CategoryRepository {
  final CategoryLocalDatasourceImpl categoryLocalDatasource;
  final QueuedActionLocalDatasourceImpl queuedActionLocalDatasource;

  CategoryRepositoryImpl({
    required this.categoryLocalDatasource,
    required this.queuedActionLocalDatasource,
  });

  @override
  Future<Result<List<CategoryEntity>>> getAllCategory() async {
    try {
      var local = await categoryLocalDatasource.getAllCategory();
      if (local.isFailure) return Result.failure(error: local.error!);

      final data = local.data ?? [];

      return Result.success(
        data: data.map((e) => e.toEntity()).toList(),
      );
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<CategoryEntity?>> getCategory(int id) async {
      try {
        var local = await categoryLocalDatasource.getCategory(id);
        if (local.isFailure) return Result.failure(error: local.error!);

        return Result.success(data: local.data?.toEntity());
      } catch (e) {
        return Result.failure(error: e);
      }
  }

  @override
  Future<Result<int>> createCategory(CategoryEntity category) async {
    try {
      var local = await categoryLocalDatasource.createCategory(CategoryModel.fromEntity(category));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'CategoryRepositoryImpl',
          method: 'createCategory',
          param: jsonEncode((CategoryModel.fromEntity(category)..id = local.data!).toJson()),
          isCritical: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: local.data!);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> updateCategory(CategoryEntity category) async {
    try {
      final local = await categoryLocalDatasource.updateCategory(CategoryModel.fromEntity(category));
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'CategoryRepositoryImpl',
          method: 'updateCategory',
          param: jsonEncode(CategoryModel.fromEntity(category).toJson()),
          isCritical: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  @override
  Future<Result<void>> deleteCategory(int id) async {
    try {
      final local = await categoryLocalDatasource.deleteCategory(id);
      if (local.isFailure) return Result.failure(error: local.error!);

      final res = await queuedActionLocalDatasource.createQueuedAction(
        QueuedActionModel(
          id: DateTime.now().millisecondsSinceEpoch,
          repository: 'CategoryRepositoryImpl',
          method: 'deleteCategory',
          param: id.toString(),
          isCritical: false,
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (res.isFailure) return Result.failure(error: res.error!);

      return Result.success(data: null);
    } catch (e) {
      return Result.failure(error: e);
    }
  }
}
