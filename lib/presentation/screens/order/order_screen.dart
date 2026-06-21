import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/order/order_filter_notifier.dart';
import '../../providers/order/order_notifier.dart';
import '../../providers/user/user_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/order_card.dart';

class OrderScreen extends ConsumerStatefulWidget {
  const OrderScreen({super.key});

  @override
  ConsumerState<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ConsumerState<OrderScreen> {
  List<CategoryEntity> allCategory = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(orderNotifierProvider.notifier).getAllOrder(true);
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
      ref.read(userNotifierProvider.notifier).getAllUser();
    });
    super.initState();
  }

  void createOrder() async {
    final result = await context.push('/order/order-create');
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [_AddButton(onCreate: createOrder, onDetail: toDetailOrder,)],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderNotifierProvider.notifier).reload(),
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
                  child: _OrderFilterBar(onSearch: () {
                    ref.read(orderNotifierProvider.notifier).reload();
                  })
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
                        onTapButton: () => createOrder(),
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
                          child: _OrderCard(
                              order: allOrder[i],
                              onTap: updateOrder
                          ),
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
  const _AddButton({
    required this.onCreate,
    required this.onDetail
  });

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
    (OrderStatus.pending.value, OrderStatus.pending.label),
    (OrderStatus.shipping.value, OrderStatus.shipping.label),
    (OrderStatus.completed.value, OrderStatus.completed.label),
    (OrderStatus.cancelled.value, OrderStatus.cancelled.label),
  ];

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day);
    DateTime toDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final filter = ref.read(orderFilterProvider);
    if (filter.fromDate != null) {
      fromDate = filter.fromDate!;
    }
    if (filter.fromDate != null) {
      toDate = DateTime(filter.toDate!.year, filter.toDate!.month, filter.toDate!.day, 23, 59, 59, 999);
    }

    fromController.text = DateFormat('dd/MM/yyyy').format(fromDate);
    toController.text = DateFormat('dd/MM/yyyy').format(toDate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onSearch(); // auto trigger search
    });
  }

  @override
  Widget build(BuildContext context) {
    final allUser = ref.watch(userNotifierProvider.select((s) => s.allUser)) ?? [];

    final filter = ref.watch(orderFilterProvider);

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
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),

        _UserAutocomplete(
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
          ],
        ),
      ],
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
    return OrderCard(
      order: order,
      onTap: () => onTap(order.id!),
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
            controller.text.isEmpty
                ? ''
                : controller.text,
          ),
        ),
      ),
    );
  }
}

class _UserAutocomplete extends StatelessWidget {
  final int? selected;
  final List<UserEntity> users;
  final ValueChanged<int?> onChanged;
  final VoidCallback onClear;

  const _UserAutocomplete({
    super.key,
    required this.selected,
    required this.users,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Autocomplete<UserEntity>(
        displayStringForOption: (u) => u.name ?? '',

        optionsBuilder: (TextEditingValue value) {
          final query = value.text.trim().toLowerCase();

          if (query.isEmpty) return users;

          return users.where(
                (u) => (u.name ?? '').toLowerCase().contains(query),
          );
        },

        onSelected: (UserEntity user) {
          FocusScope.of(context).unfocus();
          onChanged(user.id);
        },

        fieldViewBuilder:(context, textController, focusNode, onFieldSubmitted) {
          final selectedUser = selected == null
              ? null
              : users.where((u) => u.id == selected).firstOrNull;

          // 🔥 sync từ state -> text
          if (selectedUser != null
              &&
              textController.text != selectedUser.name
          ) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              textController.text = selectedUser.name ?? '';
            });
          }

          return SizedBox(
            height: 40,
            child: TextFormField(
              controller: textController,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),

              onChanged: (value) {
                // 🔥 quan trọng: nếu user xoá text → reset filter
                if (value.trim().isEmpty) {
                  onClear();
                  onChanged(null);
                }
              },

              decoration: InputDecoration(
                labelText: 'Chọn khách hàng',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),

                suffixIcon:
                (textController.text.isNotEmpty || selected != null)
                    ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    onClear();
                    textController.clear();
                    onChanged(null);
                  },
                )
                    : null,
              ),
            ),
          );
        },

        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(option.name ?? ''),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}