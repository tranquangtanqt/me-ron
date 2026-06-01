import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/order/order_form_notifier.dart';
import '../../providers/order/order_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_loading_more_indicator.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import 'components/order_card.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  final scrollController = ScrollController();
  final searchFieldController = TextEditingController();
  List<CategoryEntity> allCategory = [];

  @override
  void initState() {
    scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).getAllOrder();
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
    });
    super.initState();
  }

  void updateOrder(int id) {
    context.push('/order/order-edit/$id');
  }

  void deleteOrder(int id) async {
    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).deleteOrder(id);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      // context.go('/orders');
      ref.read(orderNotifierProvider.notifier).getAllOrder();
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
    final ordersState = ref.read(orderNotifierProvider);

    // Automatically load more data on end of scroll position
    if (scrollController.offset == scrollController.position.maxScrollExtent) {
      await ref
          .read(orderNotifierProvider.notifier)
          .getAllOrder(
            offset: ordersState.allOrder?.length,
            contains: searchFieldController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(orderNotifierProvider, (previous, next) {
      print("error: ${next.error}");
      print("data: ${next.allOrder}");
    });

    final allOrder = ref.watch(orderNotifierProvider.select((s) => s.allOrder));
    final isLoadingMore = ref.watch(orderNotifierProvider.select((s) => s.isLoadingMore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: const [_AddButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderNotifierProvider.notifier).getAllOrder(),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            controller: scrollController,
            // Disable scroll when data is null or empty
            physics: (allOrder?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
            slivers: [
              // SliverAppBar(
              //   floating: true,
              //   snap: true,
              //   automaticallyImplyLeading: false,
              //   collapsedHeight: 70,
              //   titleSpacing: 0,
              //   title: Padding(
              //     padding: const EdgeInsets.symmetric(horizontal: AppSizes.padding),
              //     child: _SearchField(controller: searchFieldController),
              //   ),
              // ),
              SliverLayoutBuilder(
                builder: (context, _) {
                  if (allOrder == null) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppProgressIndicator(),
                    );
                  }

                  if (allOrder.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppEmptyState(
                        subtitle: 'Hiện tại không có order nào, hãy thêm order để tiếp tục.',
                        buttonText: 'Thêm',
                        onTapButton: () => context.push('/order/order-create'),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                    sliver: SliverList.builder(
                      itemCount: allOrder.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.padding / 2,
                          ),
                          child: _OrderCard(order: allOrder[i]),
                        );
                      },
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
              'Thêm',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        onTap: () => context.go('/order/order-create'),
      ),
    );
  }
}


class _OrderCard extends StatelessWidget {
  final OrderModel order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    return OrderCard(
      order: order,
      onTap: () => context.go('/order/order-edit/${order.id}'),
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
        ref.read(orderNotifierProvider.notifier).resetOrder();
        ref.read(orderNotifierProvider.notifier).getAllOrder(contains: controller.text);
      },
      onTapClearButton: () {
        ref.read(orderNotifierProvider.notifier).getAllOrder(contains: controller.text);
      },
    );
  }
}