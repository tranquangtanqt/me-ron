import '../../../domain/entities/category_entity.dart';

class CategoryState {
  final List<CategoryEntity>? allCategory;
  final bool isLoadingMore;
  final String? error;

  const CategoryState({
    this.allCategory,
    this.isLoadingMore = false,
    this.error
  });

  CategoryState copyWith({
    List<CategoryEntity>? allCategory,
    bool? isLoadingMore,
    String? error
  }) {
    return CategoryState(
      allCategory: allCategory ?? this.allCategory,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
