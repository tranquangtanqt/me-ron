import '../../core/common/result.dart';
import '../entities/category_entity.dart';

abstract class CategoryRepository {
  Future<Result<List<CategoryEntity>>> getAllCategory();
  Future<Result<CategoryEntity?>> getCategory(int id);
  Future<Result<int>> createCategory(CategoryEntity category);
  Future<Result<void>> updateCategory(CategoryEntity category);
  Future<Result<void>> deleteCategory(int id);
}