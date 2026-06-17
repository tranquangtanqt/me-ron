import 'package:flutter/material.dart';
import 'package:flutter_pos/core/constants/constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/order_status.dart';
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
import 'components/order_card.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  // final scrollController = ScrollController();
  final searchFieldController = TextEditingController();
  List<CategoryEntity> allCategory = [];

  @override
  void initState() {
    // scrollController.addListener(scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).getAllOrder(true);
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
      AppSnackBar.show('Xóa dữ liệu thành công!');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  void dispose() {
    // scrollController.removeListener(scrollListener);
    // scrollController.dispose();
    searchFieldController.dispose();
    super.dispose();
  }

  // void scrollListener() {
  //   final notifier = ref.read(orderNotifierProvider.notifier);
  //   final state = ref.read(orderNotifierProvider);
  //
  //   if (!scrollController.hasClients) return;
  //   if (state.isLoadingMore) return;
  //
  //   final max = scrollController.position.maxScrollExtent;
  //   final current = scrollController.position.pixels;
  //
  //   if (current < max - 150) return;
  //
  //   final lastId = state.allOrder?.last.id;
  //   if (lastId == null) return;
  //
  //   notifier.getAllOrder(
  //     false,
  //     offset: lastId,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // ref.listen(orderNotifierProvider, (previous, next) {
    //   print("error: ${next.error}");
    //   print("data: ${next.allOrder}");
    // });

    final allOrder = ref.watch(orderNotifierProvider.select((s) => s.allOrder));
    // final isLoadingMore = ref.watch(orderNotifierProvider.select((s) => s.isLoadingMore));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: const [_AddButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderNotifierProvider.notifier).getAllOrder(false),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            // controller: scrollController,
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
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.padding,
                    vertical: 8,
                  ),
                  child: _OrderFilterBar(),
                ),
              ),
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
              // SliverToBoxAdapter(
              //   child: AppLoadingMoreIndicator(isLoading: isLoadingMore),
              // ),
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

class _OrderFilterBar extends ConsumerStatefulWidget {
  const _OrderFilterBar();

  @override
  ConsumerState<_OrderFilterBar> createState() => _OrderFilterBarState();
}

class _OrderFilterBarState extends ConsumerState<_OrderFilterBar> {
  String? selectedDateId = '99';
  int selectedStatus = OrderStatus.shipping.value;

  final statuses = [
    (-1, 'Tất cả'),
    (OrderStatus.pending.value, OrderStatus.pending.label),
    (OrderStatus.shipping.value, OrderStatus.shipping.label),
    (OrderStatus.completed.value, OrderStatus.completed.label),
    (OrderStatus.cancelled.value, OrderStatus.cancelled.label),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== CHIPS FILTER =====
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: statuses.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final item = statuses[index];
              final isSelected = selectedStatus == item.$1;

              return ChoiceChip(
                label: Text(item.$2),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    selectedStatus = item.$1;
                  });
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        // ===== DROPDOWN + SEARCH =====
        Row(
          children: [
            // DROPDOWN
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 38,
                child: DropdownButtonFormField<String>(
                  value: selectedDateId,
                  isExpanded: true,
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  style: const TextStyle(fontSize: 13),
                  items: [
                    const DropdownMenuItem(
                      value: '99',
                      child: Text('Tất cả thời gian'),
                    ),
                    ...Constants.orderDateFilters.map((c) {
                      return DropdownMenuItem(
                        value: c.$1,
                        child: Text(c.$2),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() => selectedDateId = value);
                  },
                ),
              ),
            ),

            const SizedBox(width: 8),

            // SEARCH BUTTON
            SizedBox(
              height: 38,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  DateTime? startDate;
                  DateTime? endDate;
                  DateTime now = DateTime.now();

                  if (selectedDateId == '99') {
                    // Tất cả
                  } else if (selectedDateId == '1') {
                    // Hôm nay
                    startDate = DateTime(now.year, now.month, now.day);
                  } else if (selectedDateId == '2') {
                    // Hôm qua
                    final yesterday = now.subtract(const Duration(days: 1));

                    startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);

                    endDate = DateTime(
                      yesterday.year,
                      yesterday.month,
                      yesterday.day,
                      23,
                      59,
                      59,
                      999,
                    );
                  } else if (selectedDateId == '3') {
                    // Tuần này
                    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
                    startDate = DateTime(
                      startOfWeek.year,
                      startOfWeek.month,
                      startOfWeek.day,
                    );
                  } else if (selectedDateId == '4') {
                    // Tuần trước
                    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

                    final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));

                    startDate = DateTime(
                      startOfLastWeek.year,
                      startOfLastWeek.month,
                      startOfLastWeek.day,
                    );

                    endDate = startOfThisWeek.subtract(const Duration(seconds: 1));
                  } else if (selectedDateId == '5') {
                    // Tháng này
                    startDate = DateTime(now.year, now.month, 1);
                  } else if (selectedDateId == '6') {
                    // Tháng trước
                    final now = DateTime.now();

                    final firstDayThisMonth = DateTime(now.year, now.month, 1);
                    final lastDayLastMonth = firstDayThisMonth.subtract(const Duration(days: 1));

                    startDate = DateTime(lastDayLastMonth.year, lastDayLastMonth.month, 1);
                    endDate = DateTime(
                      lastDayLastMonth.year,
                      lastDayLastMonth.month,
                      lastDayLastMonth.day,
                      23,
                      59,
                      59,
                    );
                  }
                  ref.read(orderNotifierProvider.notifier).getAllOrder(
                    true,
                  startDate: startDate,
                  endDate: endDate,
                  status: selectedStatus,
                  );
                },
                child: const Icon(Icons.search, size: 18),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// class _FilterBar extends ConsumerStatefulWidget {
//   const _FilterBar();
//
//   @override
//   ConsumerState<_FilterBar> createState() => _FilterBarState();
// }
//
// class _FilterBarState extends ConsumerState<_FilterBar> {
//   String? selectedCategoryId;
//
//   @override
//   Widget build(BuildContext context) {
//     final categories = ref.watch(
//       categoryNotifierProvider.select((s) => s.allCategory),
//     );
//
//     return Row(
//       children: [
//         // ===== COMBOBOX =====
//         Expanded(
//           child: DropdownButtonFormField<String>(
//             value: selectedCategoryId,
//             isExpanded: true,
//             decoration: const InputDecoration(
//               labelText: 'Danh mục',
//               border: OutlineInputBorder(),
//               contentPadding: EdgeInsets.symmetric(horizontal: 12),
//             ),
//             items: [
//               const DropdownMenuItem(
//                 value: null,
//                 child: Text('Tất cả'),
//               ),
//               ...?categories?.map((c) {
//                 return DropdownMenuItem(
//                   value: c.id.toString(),
//                   child: Text("c.name"),
//                   // child: Text(c.name),
//                 );
//               }),
//             ],
//             onChanged: (value) {
//               setState(() {
//                 selectedCategoryId = value;
//               });
//             },
//           ),
//         ),
//
//         const SizedBox(width: 8),
//
//         // ===== BUTTON SEARCH =====
//         SizedBox(
//           height: 48,
//           child: ElevatedButton(
//             onPressed: () {
//               // ref.read(orderNotifierProvider.notifier).getAllOrder(
//               //   true,
//               //   categoryId: selectedCategoryId,
//               // );
//             },
//             child: const Icon(Icons.search),
//           ),
//         ),
//       ],
//     );
//   }
// }

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

// class _SearchField extends ConsumerWidget {
//   final TextEditingController controller;
//
//   const _SearchField({required this.controller});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return AppTextField(
//       controller: controller,
//       hintText: 'Tìm kiếm sản phẩm...',
//       type: AppTextFieldType.search,
//       textInputAction: TextInputAction.search,
//       onEditingComplete: () {
//         FocusScope.of(context).unfocus();
//         ref.read(orderNotifierProvider.notifier).resetOrder();
//         ref.read(orderNotifierProvider.notifier).getAllOrder(contains: controller.text);
//       },
//       onTapClearButton: () {
//         ref.read(orderNotifierProvider.notifier).getAllOrder(contains: controller.text);
//       },
//     );
//   }
// }