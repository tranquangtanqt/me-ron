import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/order_sort_option.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/category_entity.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/order/order_filter_notifier.dart';
import '../../providers/order/order_notifier.dart';
import '../../providers/user/user_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_user_autocomplete.dart';
import 'components/order_card.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  List<CategoryEntity> allCategory = [];
  bool _isFilterReady = false;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderFilterProvider.notifier).reset();
      setState(() => _isFilterReady = true);

      ref.read(categoryNotifierProvider.notifier).getAllCategory();
      ref.read(userNotifierProvider.notifier).getAllUser();
    });
    super.initState();
  }

  Future<void> _search() async {
    await ref.read(orderNotifierProvider.notifier).reload();
  }

  void createOrder() async {
    final filter = ref.read(orderFilterProvider);
    final fromDate = filter.fromDate;
    final toDate = filter.toDate;

    final queryParameters = <String, String>{
      if (filter.userId != null) 'userId': '${filter.userId}',
      if (fromDate != null && toDate != null && DateUtils.isSameDay(fromDate, toDate))
        'deliveryDate': DateFormat('yyyy-MM-dd').format(fromDate),
    };

    final path = Uri(path: '/order/order-create', queryParameters: queryParameters.isEmpty ? null : queryParameters);

    final result = await context.push(path.toString());
    if (result == true) {
      ref.read(orderNotifierProvider.notifier).reload();
    }
  }

  void updateOrder(int id) async {
    final result = await context.push('/order/order-edit/$id');
    if (result == true) {
      ref.read(orderNotifierProvider.notifier).reload();
    }
  }

  void toDetailOrder() async {
    final result = await context.push('/order/order-detail');
    if (result == true) {
      ref.read(orderNotifierProvider.notifier).reload();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen(orderNotifierProvider, (previous, next) {
    //   print("error: ${next.error}");
    //   print("data: ${next.allOrder}");
    // });

    final allOrder = ref.watch(orderNotifierProvider.select((s) => s.allOrder));
    final total = ref.watch(orderNotifierProvider.select((s) => s.total));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          _AddButton(
            onCreate: createOrder,
            onDetail: toDetailOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _search,
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            physics: (allOrder?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.padding,
                    vertical: 8,
                  ),
                  child: _isFilterReady ? _OrderFilterBar(onSearch: _search) : const SizedBox.shrink(),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, _) {
                  if (total == null) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppProgressIndicator(),
                    );
                  }

                  if (total == 0) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppEmptyState(
                        subtitle: 'Hiện tại không có order nào, hãy thêm order để tiếp tục.',
                        buttonText: 'Thêm',
                        onTapButton: () => createOrder(),
                      ),
                    );
                  }

                  final loaded = allOrder ?? [];

                  if (loaded.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSizes.padding,
                            AppSizes.padding / 2,
                            AppSizes.padding,
                            AppSizes.padding,
                          ),
                          child: AppButton(
                            width: double.infinity,
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            text: 'Xem danh sách ($total)',
                            onTap: () => ref.read(orderNotifierProvider.notifier).loadMore(),
                          ),
                        ),
                      ),
                    );
                  }

                  final hasMore = loaded.length < total;

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                    sliver: SliverList.builder(
                      itemCount: loaded.length + (hasMore ? 1 : 0),
                      itemBuilder: (context, i) {
                        if (i == loaded.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: AppSizes.padding / 2),
                            child: Center(
                              child: AppButton(
                                height: 32,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                text: 'Xem thêm',
                                onTap: () => ref.read(orderNotifierProvider.notifier).loadMore(),
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.padding / 2,
                          ),
                          child: _OrderCard(order: loaded[i], onTap: updateOrder),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onCreate;
  final VoidCallback onDetail;
  const _AddButton({required this.onCreate, required this.onDetail});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ===== VIEW DETAIL BUTTON =====
          AppButton(
            height: 26,
            borderRadius: BorderRadius.circular(4),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding / 2,
            ),
            buttonColor: Theme.of(context).colorScheme.surfaceContainer,
            onTap: () => onDetail(),
            child: Row(
              children: [
                Icon(
                  Icons.visibility,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.padding / 4),
                Text(
                  'Chi tiết',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // ===== ADD BUTTON =====
          AppButton(
            height: 26,
            borderRadius: BorderRadius.circular(4),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSizes.padding / 2,
            ),
            buttonColor: Theme.of(context).colorScheme.surfaceContainer,
            onTap: () => onCreate(),
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
          ),
        ],
      ),
    );
  }
}

class _OrderFilterBar extends ConsumerStatefulWidget {
  final VoidCallback onSearch;
  const _OrderFilterBar({required this.onSearch});

  @override
  ConsumerState<_OrderFilterBar> createState() => _OrderFilterBarState();
}

class _OrderFilterBarState extends ConsumerState<_OrderFilterBar> with RouteAware {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  final statuses = [
    (-1, 'Tất cả'),
    (OrderStatus.shipping.value, OrderStatus.shipping.label),
    (OrderStatus.completed.value, OrderStatus.completed.label),
    (OrderStatus.cancelled.value, OrderStatus.cancelled.label),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSearch(); // auto trigger search
    });
  }

  @override
  void dispose() {
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allUser = ref.watch(userNotifierProvider.select((s) => s.allUser)) ?? [];

    final filter = ref.watch(orderFilterProvider);
    final now = DateTime.now();

    fromController.text = DateFormat('dd/MM/yyyy').format(filter.fromDate ?? now);
    toController.text = DateFormat('dd/MM/yyyy').format(filter.toDate ?? now);

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
              // final isSelected = selectedStatus == item.$1;
              final isSelected = filter.status == item.$1;

              return ChoiceChip(
                label: Text(item.$2),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    // selectedStatus = item.$1;
                    ref.read(orderFilterProvider.notifier).setStatus(item.$1);
                  });

                  // Auto-trigger search after changing the status
                  widget.onSearch();
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        AppUserAutocomplete(
          selected: filter.userId,
          users: allUser,
          onChanged: (userId) {
            setState(() {
              ref.read(orderFilterProvider.notifier).setUser(userId);
            });
          },
          onClear: () {
            setState(() {
              ref.read(orderFilterProvider.notifier).setUser(null);
            });
          },
        ),

        const SizedBox(height: 10),

        // ===== DATE + SEARCH =====
        Row(
          children: [
            // DATE
            Expanded(
              child: _DateField(
                label: 'Từ ngày',
                controller: fromController,
                onChanged: (date) {
                  setState(() {
                    // fromDate = date;
                    ref.read(orderFilterProvider.notifier).setFromDate(date);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _DateField(
                label: 'Đến ngày',
                controller: toController,
                onChanged: (date) {
                  setState(() {
                    // toDate = date;
                    ref.read(orderFilterProvider.notifier).setToDate(date);
                  });
                },
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
                onPressed: () async {
                  await Future.microtask(() {});
                  widget.onSearch();
                },
                child: const Icon(Icons.search, size: 18),
              ),
            ),

            _OrderSortButton(
              selected: filter.sortOption,
              onSelected: (option) {
                ref.read(orderFilterProvider.notifier).setSortOption(option);
                widget.onSearch();
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _OrderSortButton extends StatelessWidget {
  final OrderSortOption? selected;
  final ValueChanged<OrderSortOption> onSelected;

  const _OrderSortButton({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<OrderSortOption>(
      tooltip: 'Sắp xếp',
      icon: Icon(
        Icons.sort,
        size: 20,
        color: selected != null ? Theme.of(context).colorScheme.primary : null,
      ),
      onSelected: onSelected,
      itemBuilder: (context) {
        return OrderSortOption.values.map((option) {
          return CheckedPopupMenuItem(
            value: option,
            checked: option == selected,
            child: Text(option.label),
          );
        }).toList();
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<int> onTap;

  const _OrderCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color? bg;
    final status = order.status;
    if (status != null) {
      try {
        final st = OrderStatusExtension.fromValue(status);
        bg = st.color;
      } catch (_) {
        bg = null;
      }
    }

    return OrderCard(
      order: order,
      onTap: () => onTap(order.id!),
      backgroundColor: bg,
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();

    if (controller.text.isNotEmpty) {
      try {
        initialDate = DateFormat('dd/MM/yyyy').parse(controller.text);
      } catch (_) {}
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      controller.text = DateFormat(
        'dd/MM/yyyy',
      ).format(picked);

      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: InkWell(
        onTap: () => _pickDate(context),
        child: InputDecorator(
          isEmpty: controller.text.isEmpty,
          decoration: InputDecoration(
            labelText: label,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            // suffixIcon: const Icon(
            //   Icons.calendar_month_rounded,
            //   size: 18,
            // ),
          ),
          child: Text(
            controller.text.isEmpty ? '' : controller.text,
          ),
        ),
      ),
    );
  }
}
