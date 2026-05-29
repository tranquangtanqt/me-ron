import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/products/product_form_notifier.dart';
import '../../providers/products/products_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import 'components/products_card.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  final scrollController = ScrollController();
  final searchFieldController = TextEditingController();
  List<CategoryEntity> allCategory = [];

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(productsNotifierProvider.notifier).getAllProducts();
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
    });
    super.initState();
  }

  void updateProduct(int id) {
    context.push('/products/product-edit/$id');
  }

  void deleteProduct(int id) async {
    var res = await AppDialog.showProgress(() {
      return ref.read(productFormNotifierProvider.notifier).deleteProduct(id);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      // context.go('/products');
      ref.read(productsNotifierProvider.notifier).getAllProducts();
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  void scrollListener() async {
    final productsState = ref.read(productsNotifierProvider);

    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref
          .read(productsNotifierProvider.notifier)
          .getAllProducts(
            offset: productsState.allProducts?.length,
            contains: searchFieldController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(productsNotifierProvider, (previous, next) {
      print("error: ${next.error}");
      print("data: ${next.allProducts}");
    });

    final allProducts = ref.watch(productsNotifierProvider.select((s) => s.allProducts));
    final isLoadingMore = ref.watch(productsNotifierProvider.select((s) => s.isLoadingMore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: const [_AddButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(productsNotifierProvider.notifier).getAllProducts(),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            controller: scrollController,
            // Disable scroll when data is null or empty
            physics: (allProducts?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
            slivers: [
              SliverAppBar(
                floating: true,
                snap: true,
                automaticallyImplyLeading: false,
                collapsedHeight: 70,
                titleSpacing: 0,
                title: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
                  child: _SearchField(controller: searchFieldController),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, _) {
                  if (allProducts == null) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppProgressIndicator(),
                    );
                  }

                  if (allProducts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppEmptyState(
                        subtitle: 'Hiện tại không có sản phẩm nào, hãy thêm sản phẩm để tiếp tục.',
                        buttonText: 'Thêm sản phẩm',
                        onTapButton: () => context.push('/products/product-create'),
                      ),
                    );
                  }

                  return SliverToBoxAdapter(
                    child: Align(
                    alignment: Alignment.topLeft,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppSizes.padding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSizes.padding),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columnSpacing: 25, // giảm khoảng cách giữa các cột
                              horizontalMargin: 8,
                              dataRowMinHeight: 40,
                              dataRowMaxHeight: 48,
                              dividerThickness: 0, // tắt line mặc định
                              // border: TableBorder.all(
                              //   color: Colors.grey,
                              //   width: 1,
                              // ),
                              columns: const [
                                DataColumn(label: Padding(
                                  padding: EdgeInsets.only(left: 8),
                                  child: Text('id'),
                                ),),
                                DataColumn(label: Text('Tên')),
                                DataColumn(label: Text('Giá')),
                                // DataColumn(label: Text('cate')),
                                DataColumn(label: Text('Tùy chọn')),
                              ],
                              rows: (allProducts ?? []).map((item) {
                                return DataRow(
                                  cells: [
                                    DataCell(Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Text(item.id.toString()),
                                    ),),
                                    DataCell(Text(item.name ?? '')),
                                    DataCell(Text(item.price.toString() ?? '')),
                                    // DataCell(Text(item.categoryId.toString() ?? '')),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit, color: Colors.orange),
                                            onPressed: () {
                                              updateProduct(item.id!);
                                            },
                                          ),
                                          IconButton(
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                            onPressed: () {
                                              AppDialog.show(
                                                title: 'Xác nhận',
                                                text: 'Bạn có chắc chắn muốn xóa dữ liệu?',
                                                leftButtonText: 'Hủy bỏ',
                                                rightButtonText: 'Xóa',
                                                rightButtonColor: Theme.of(context).colorScheme.errorContainer,
                                                rightButtonTextColor: Theme.of(context).colorScheme.error,
                                                onTapRightButton: (context) async {
                                                  context.pop();
                                                  deleteProduct(item.id!);
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),
              SliverToBoxAdapter(
                child: AppLoadingMoreIndicator(isLoading: isLoadingMore),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: AppButton(
        height: 26,
        borderRadius: BorderRadius.circular(4),
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding / 2),
        buttonColor: Theme.of(context).colorScheme.surfaceContainer,
        child: Row(
          children: [
            Icon(
              Icons.add,
              size: 12,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: AppSizes.padding / 4),
            Text(
              'Add Product',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () => context.go('/products/product-create'),
      ),
    );
  }
}

class _SearchField extends ConsumerWidget {
  final TextEditingController controller;

  const _SearchField({required this.controller});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTextField(
      controller: controller,
      hintText: 'Tìm kiếm sản phẩm...',
      type: AppTextFieldType.search,
      textInputAction: TextInputAction.search,
      onEditingComplete: () {
        FocusScope.of(context).unfocus();
        ref.read(productsNotifierProvider.notifier).resetProducts();
        ref.read(productsNotifierProvider.notifier).getAllProducts(contains: controller.text);
      },
      onTapClearButton: () {
        ref.read(productsNotifierProvider.notifier).getAllProducts(contains: controller.text);
      },
    );
  }
}

// class _ProductCard extends StatelessWidget {
//   final ProductEntity product;
//
//   const _ProductCard({required this.product});
//
//   @override
//   Widget build(BuildContext context) {
//     return ProductsCard(
//       product: product,
//       onTap: () => context.go('/products/product-detail/${product.id}'),
//     );
//   }
// }
