import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';

class ProductsState {
  final List<ProductEntity>? allProducts;
  final int? categoryId;
  final bool isLoadingMore;
  final String? error;

  const ProductsState({
    this.allProducts,
    this.categoryId,
    this.isLoadingMore = false,
    this.error
  });

  ProductsState copyWith({
    List<ProductEntity>? allProducts,
    int? categoryId,
    bool? isLoadingMore,
    String? error
  }) {
    return ProductsState(
      allProducts: allProducts ?? this.allProducts,
      categoryId: categoryId ?? this.categoryId,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}
