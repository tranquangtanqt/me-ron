import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/usecases/category_usecases.dart';
import '../base/base_form_notifier.dart';
import 'category_form_state.dart';
import 'category_notifier.dart';

final categoryFormNotifierProvider = NotifierProvider.autoDispose<CategoryFormNotifier, CategoryFormState>(
  CategoryFormNotifier.new,
);

class CategoryFormNotifier extends BaseFormNotifier<CategoryFormState> {
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
    return performCreate(
      execute: () async {
        final categoryRepository = ref.read(categoryRepositoryProvider);
        final category = CategoryEntity(
          name: state.name ?? '',
          description: state.description ?? '',
        );
        return await CreateCategoryUsecase(categoryRepository).call(category);
      },
      onSuccess: () => ref.read(categoryNotifierProvider.notifier).getAllCategory(),
    );
  }

  Future<Result<void>> updatedCategory(int id) async {
    return performUpdate(
      execute: () async {
        final categoryRepository = ref.read(categoryRepositoryProvider);
        final category = CategoryEntity(
          id: id,
          name: state.name!,
          description: state.description,
        );
        return await UpdateCategoryUsecase(categoryRepository).call(category);
      },
      onSuccess: () => ref.read(categoryNotifierProvider.notifier).getAllCategory(),
    );
  }

  Future<Result<void>> deleteCategory(int id) async {
    return performDelete(
      execute: () async {
        final categoryRepository = ref.read(categoryRepositoryProvider);
        return await DeleteCategoryUsecase(categoryRepository).call(id);
      },
      onSuccess: () => ref.read(categoryNotifierProvider.notifier).getAllCategory(),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(categoryNotifierProvider.notifier).getAllCategory();
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }

  void onChangedDescription(String value) {
    state = state.copyWith(description: value);
  }
}
