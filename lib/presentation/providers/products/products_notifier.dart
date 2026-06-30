import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../domain/usecases/params/base_params.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../auth/auth_notifier.dart';
import 'products_state.dart';

final productsNotifierProvider = NotifierProvider<ProductsNotifier, ProductsState>(
  ProductsNotifier.new,
);

class ProductsNotifier extends Notifier<ProductsState> {
  @override
  ProductsState build() {
    return const ProductsState();
  }

  void resetProducts() {
    state = const ProductsState();
  }

  Future<void> getAllProducts({int? offset, String? contains}) async {
    try {
      if (offset != null) {
        state = state.copyWith(isLoadingMore: true);
      } else {
        state = state.copyWith(allProducts: null, clearError: true);
      }

      var params = BaseParams(
        orderBy: 'id',
        sortBy: 'ASC',
        offset: offset,
      );

      final productRepository = ref.read(productRepositoryProvider);
      var res = await GetAllProductsUsecase(productRepository).call(params);

      if (res.isSuccess) {
        if (offset == null) {
          state = state.copyWith(allProducts: res.data ?? [], isLoadingMore: false, clearError: true);
        } else {
          final current = state.allProducts ?? [];
          state = state.copyWith(
            allProducts: [...current, ...res.data ?? []],
            isLoadingMore: false,
            clearError: true,
          );
        }
      } else {
        final errorMsg = res.error?.toString() ?? 'Failed to load data';
        state = state.copyWith(isLoadingMore: false, error: errorMsg);
      }
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}
