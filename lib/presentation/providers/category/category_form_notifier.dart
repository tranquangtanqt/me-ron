import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category_usecases.dart';
import 'category_form_state.dart';
import 'category_notifier.dart';

final categoryFormNotifierProvider = NotifierProvider.autoDispose<CategoryFormNotifier, CategoryFormState>(
  CategoryFormNotifier.new,
);

class CategoryFormNotifier extends AutoDisposeNotifier<CategoryFormState> {
  @override
  CategoryFormState build() {
    return const CategoryFormState();
  }

  Future<void> initCategoryForm(int? id) async {
    if (id == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final categoryRepository = ref.read(categoryRepositoryProvider);
    var res = await GetCategoryUsecase(categoryRepository).call(id);

    if (res.isSuccess) {
      var category = res.data;

      state = state.copyWith(
        name: category?.name,
        description: category?.description,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createCategory() async {
    try {
      final categoryRepository = ref.read(categoryRepositoryProvider);

      var category = CategoryEntity(
        name: state.name ?? '',
        description: state.description ?? '',
      );

      var res = await CreateCategoryUsecase(categoryRepository).call(category);

      // Refresh category
      ref.read(categoryNotifierProvider.notifier).getAllCategory();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> updatedCategory(int id) async {
    try {
      final categoryRepository = ref.read(categoryRepositoryProvider);

      var category = CategoryEntity(
        id: id,
        name: state.name!,
        description: state.description,
      );

      var res = await UpdateCategoryUsecase(categoryRepository).call(category);

      // Refresh category
      ref.read(categoryNotifierProvider.notifier).getAllCategory();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  Future<Result<void>> deleteCategory(int id) async {
    try {
      final categoryRepository = ref.read(categoryRepositoryProvider);
      var res = await DeleteCategoryUsecase(categoryRepository).call(id);

      // Refresh category
      ref.read(categoryNotifierProvider.notifier).getAllCategory();

      return res;
    } catch (e) {
      return Result.failure(error: e);
    }
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }

  void onChangedDescription(String value) {
    state = state.copyWith(description: value);
  }
}
