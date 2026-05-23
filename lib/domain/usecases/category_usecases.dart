import '../../core/common/result.dart';
import '../../core/usecase/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/category_repository.dart';
import 'params/base_params.dart';

class GetAllCategoryUsecase extends Usecase<Result, BaseParams> {
  GetAllCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<List<CategoryEntity>>> call(BaseParams params) async => _categoryRepository.getAllCategory();
}

class GetCategoryUsecase extends Usecase<Result, int> {
  GetCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<CategoryEntity?>> call(int params) async => _categoryRepository.getCategory(params);
}

class CreateCategoryUsecase extends Usecase<Result, CategoryEntity> {
  CreateCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<int>> call(CategoryEntity params) async {
    if (params.id != null) {
      final currentCategory = await _categoryRepository.getCategory(params.id!);
      if (currentCategory.data != null) {
        return Result.success(data: currentCategory.data!.id!);
      }
    }

    return await _categoryRepository.createCategory(params);
  }
}

class UpdateCategoryUsecase extends Usecase<Result<void>, CategoryEntity> {
  UpdateCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<void>> call(CategoryEntity params) async => _categoryRepository.updateCategory(params);
}

class DeleteCategoryUsecase extends Usecase<Result<void>, int> {
  DeleteCategoryUsecase(this._categoryRepository);

  final CategoryRepository _categoryRepository;

  @override
  Future<Result<void>> call(int params) async => _categoryRepository.deleteCategory(params);
}
