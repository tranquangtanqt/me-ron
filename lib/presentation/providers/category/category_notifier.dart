import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/category_usecases.dart';
import 'category_state.dart';

final categoryNotifierProvider = NotifierProvider<CategoryNotifier, CategoryState>(
  CategoryNotifier.new,
);

class CategoryNotifier extends Notifier<CategoryState> {
  @override
  CategoryState build() {
    return const CategoryState();
  }

  void resetCategory() {
    state = const CategoryState();
  }

  Future<void> getAllCategory({int? offset}) async {
    try {
      if (offset != null) {
        state = state.copyWith(isLoadingMore: true);
      }

      var params = BaseParams(
        offset: offset,
      );

      final categoryRepository = ref.read(categoryRepositoryProvider);
      var res = await GetAllCategoryUsecase(categoryRepository).call(params);

      if (res.isSuccess) {
        if (offset == null) {
          state = state.copyWith(
              allCategory: res.data ?? [],
              isLoadingMore: false,
              error: null,
          );
        } else {
          final current = state.allCategory ?? [];
          state = state.copyWith(
            allCategory: [...current, ...res.data ?? []],
            isLoadingMore: false,
          );
        }
      } else {
        state = state.copyWith(
            isLoadingMore: false,
            error: res.error?.toString(),
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}
