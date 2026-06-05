import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/common/result.dart';
import '../../../core/utilities/console_logger.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/usecases/product_usecases.dart';
import '../base/base_form_notifier.dart';
import 'product_form_state.dart';
import 'products_notifier.dart';

final productFormNotifierProvider = NotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
  ProductFormNotifier.new,
);

class ProductFormNotifier extends BaseFormNotifier<ProductFormState> {
  @override
  ProductFormState build() {
    return const ProductFormState();
  }

  Future<void> initProductForm(int? productId) async {
    if (productId == null) {
      state = state.copyWith(isLoaded: true);
      return;
    }

    final productRepository = ref.read(productRepositoryProvider);
    var res = await GetProductUsecase(productRepository).call(productId);

    if (res.isSuccess) {
      var product = res.data;

      state = state.copyWith(
        imageUrl: product?.imageUrl,
        categoryId: product?.categoryId,
        name: product?.name,
        price: product?.price,
        description: product?.description,
        isLoaded: true,
      );
    } else {
      throw res.error ?? 'Failed to load data';
    }
  }

  Future<Result<int>> createProduct() async {
    return performCreate(
      execute: () async {
        final productRepository = ref.read(productRepositoryProvider);
        final imageUrl = state.imageUrl;

        cl('imageUrl $imageUrl');

        final product = ProductEntity(
          categoryId: state.categoryId,
          name: state.name ?? '',
          imageUrl: imageUrl ?? '',
          price: state.price ?? 0,
          description: state.description ?? '',
        );

        return await CreateProductUsecase(productRepository).call(product);
      },
      onSuccess: () => ref.read(productsNotifierProvider.notifier).getAllProducts(),
    );
  }

  Future<Result<void>> updatedProduct(int id) async {
    return performUpdate(
      execute: () async {
        final productRepository = ref.read(productRepositoryProvider);
        final imageUrl = state.imageUrl;

        cl('imageUrl $imageUrl');

        final product = ProductEntity(
          id: id,
          categoryId: state.categoryId,
          name: state.name!,
          imageUrl: imageUrl ?? '',
          price: state.price ?? 0,
          description: state.description ?? '',
        );

        return await UpdateProductUsecase(productRepository).call(product);
      },
      onSuccess: () => ref.read(productsNotifierProvider.notifier).getAllProducts(),
    );
  }

  Future<Result<void>> deleteProduct(int id) async {
    return performDelete(
      execute: () async {
        final productRepository = ref.read(productRepositoryProvider);
        return await DeleteProductUsecase(productRepository).call(id);
      },
      onSuccess: () => ref.read(productsNotifierProvider.notifier).getAllProducts(),
    );
  }

  @override
  void refreshParentNotifier() {
    ref.read(productsNotifierProvider.notifier).getAllProducts();
  }

  void onChangedImage(File value) {
    state = state.copyWith(imageFile: value);
  }

  void onChangedCategory(int? value) {
    state = state.copyWith(categoryId: value);
  }

  void onChangedName(String value) {
    state = state.copyWith(name: value);
  }

  void onChangedPrice(String value) {
    state = state.copyWith(price: int.tryParse(value));
  }

  void onChangedDesc(String value) {
    state = state.copyWith(description: value);
  }
}
