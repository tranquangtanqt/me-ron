import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

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
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
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
        title: const Text('Đặt món'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: const [_AddButton()],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderNotifierProvider.notifier).getAllOrder(false),
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
  int selectedStatus = OrderStatus.shipping.value;
  DateTime now = DateTime.now();
  late DateTime fromDate = DateTime(now.year, now.month, now.day);
  late DateTime toDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

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

    fromController.text = DateFormat('dd/MM/yyyy').format(fromDate);
    toController.text = DateFormat('dd/MM/yyyy').format(toDate);
  }

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
                    fromDate = date;
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
                    toDate = date;
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
                onPressed: () {
                  toDate = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59, 999);

                  ref.read(orderNotifierProvider.notifier).getAllOrder(
                    true,
                    fromDate: fromDate,
                    toDate: toDate,
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
            suffixIcon: const Icon(
              Icons.calendar_month_rounded,
              size: 18,
            ),
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