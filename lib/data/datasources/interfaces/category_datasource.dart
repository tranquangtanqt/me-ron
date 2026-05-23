import '../../../core/common/result.dart';
import '../../models/category_model.dart';

abstract class CategoryDatasource {
  Future<Result<List<CategoryModel>>> getAllCategory();

  Future<Result<CategoryModel?>> getCategory(int id);

  Future<Result<int>> createCategory(CategoryModel categoryModel);

  Future<Result<void>> updateCategory(CategoryModel categoryModel);

  Future<Result<void>> deleteCategory(int id);
}
