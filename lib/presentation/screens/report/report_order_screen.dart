import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/constants.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/report/order/report_order_filter_notifier.dart';
import '../../providers/report/order/report_order_notifier.dart';
import '../../providers/user/user_notifier.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/report_order_card.dart';

class ReportOrderScreen extends ConsumerStatefulWidget {
  const ReportOrderScreen({super.key});

  @override
  ConsumerState<ReportOrderScreen> createState() => _ReportOrderScreenState();
}

class _ReportOrderScreenState extends ConsumerState<ReportOrderScreen> {
  List<CategoryEntity> allCategory = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
      ref.read(userNotifierProvider.notifier).getAllUser();
    });
    super.initState();
  }

  void updateOrder(int id) async {
    final result = await context.push('/order/order-edit/$id');
    if (result == true) {
      ref.read(reportOrderNotifierProvider.notifier).reloadByReportOrder();
    }
  }

  void toDetailOrder() async {
    final result = await context.push('/order/order-detail');
    if (result == true) {
      ref.read(reportOrderNotifierProvider.notifier).reloadByReportOrder();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final allOrder = ref.watch(reportOrderNotifierProvider.select((s) => s.allOrder));
    final productSummary = ref.watch(reportOrderNotifierProvider.select((s) => s.productSummary));
    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    final orderSummaryByStatus = <OrderStatus, _OrderSummary>{};
    for (final status in OrderStatus.values) {
      orderSummaryByStatus[status] = const _OrderSummary();
    }

    if (allOrder != null && allOrder.isNotEmpty) {
      for (final order in allOrder) {
        final status = OrderStatusExtension.fromValue(order.status ?? OrderStatus.shipping.value);
        final current = orderSummaryByStatus[status] ?? const _OrderSummary();
        orderSummaryByStatus[status] = _OrderSummary(
          count: current.count + 1,
          totalAmount: current.totalAmount + (order.total ?? 0),
        );
      }
    }

    final totalOrderCount = allOrder?.length ?? 0;
    // final totalOrderAmount = allOrder?.fold<int>(0, (sum, order) => sum + (order.total ?? 0)) ?? 0;

    final totalOrderAmount =
        allOrder
            ?.where((o) {
          final status = OrderStatusExtension.fromValue(
            o.status ?? OrderStatus.shipping.value,
          );
          return status != OrderStatus.cancelled;
        })
            .fold<int>(0, (sum, order) => sum + (order.total ?? 0)) ??
            0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê theo đơn hàng'),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportOrderNotifierProvider.notifier).reloadByReportOrder(),
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
                  child: _ReportOrderFilterBar(onSearch: () {
                    ref.read(reportOrderNotifierProvider.notifier).reloadByReportOrder();
                  })
                ),
              ),
              if (allOrder != null && allOrder.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.padding,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng cộng theo đơn hàng',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryMetricTitle2Row(
                                    title: 'Tổng số đơn',
                                    value: '$totalOrderCount',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _SummaryMetricTitle2Row(
                                    title: 'Tổng thành tiền',
                                    value: '${currencyFormat.format(totalOrderAmount)} đ',
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: orderSummaryByStatus.entries
                                    .where((entry) => entry.value.count > 0)
                                    .map((entry) {
                                  final status = entry.key;
                                  final summary = entry.value;
                                  final statusLabel = OrderStatusExtension(status).label;
                                  final statusColor = status == OrderStatus.completed
                                      ? Colors.green
                                      : status == OrderStatus.cancelled
                                          ? Colors.red
                                          : Colors.orange;

                                  return Container(
                                    width: 165,
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.09),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: statusColor.withOpacity(0.25),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          statusLabel,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Số đơn: ${summary.count}',
                                          style: const TextStyle(fontSize: 13),
                                        ),
                                        const SizedBox(height: 4),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Tiền: ${currencyFormat.format(summary.totalAmount)} đ',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: statusColor,
                                            ),
                                          ),
                                        ),

                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              if (productSummary != null && productSummary.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.padding,
                      vertical: 8,
                    ),
                    child: Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Tổng cộng theo món',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // TOTAL
                            Text(
                              'Tổng số món: ${productSummary.values.fold<int>(0, (s, e) => s + e.quantity)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // LIST
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: (productSummary.values.toList()
                                  ..sort((a, b) => b.quantity.compareTo(a.quantity)))
                                    .map((e) {
                                  return Container(
                                    margin: const EdgeInsets.only(right: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.2),
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          e.productName,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '${e.quantity}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      child: AppEmptyState(),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSizes.padding,
                      2,
                      AppSizes.padding,
                      AppSizes.padding,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          const SizedBox(height: 6),

                          // ===== SECTION HEADER =====
                          Row(
                            children: const [
                              Icon(Icons.list_alt, size: 18),
                              SizedBox(width: 6),
                              Text(
                                'Chi tiết đơn hàng',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 6),
                          const Divider(thickness: 1),

                          const SizedBox(height: 4),

                          // ===== LIST =====
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allOrder.length,
                            separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSizes.padding / 2),
                            itemBuilder: (context, i) {
                              return _ReportOrderCard(
                                order: allOrder[i],
                                onTap: updateOrder,
                              );
                            },
                          ),
                        ],
                      ),
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

class _SummaryMetricTitle2Row extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryMetricTitle2Row({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderSummary {
  final int count;
  final int totalAmount;

  const _OrderSummary({this.count = 0, this.totalAmount = 0});
}

class _ReportOrderFilterBar extends ConsumerStatefulWidget {
  final VoidCallback onSearch;
  const _ReportOrderFilterBar({required this.onSearch});

  @override
  ConsumerState<_ReportOrderFilterBar> createState() => _ReportOrderFilterBarState();
}

class _ReportOrderFilterBarState extends ConsumerState<_ReportOrderFilterBar> with RouteAware {
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

    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day, 00, 00, 00, 000);
    DateTime toDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final filter = ref.read(reportOrderFilterProvider);
    if (filter.fromDate != null) {
      fromDate = DateTime(filter.fromDate!.year, filter.fromDate!.month, filter.fromDate!.day, 00, 00, 00, 000);
    }
    if (filter.toDate != null) {
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

    final filter = ref.watch(reportOrderFilterProvider);

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
              final isSelected = filter.status == item.$1;

              return ChoiceChip(
                label: Text(item.$2),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    ref.read(reportOrderFilterProvider.notifier).setStatus(item.$1);
                  });

                  // Auto-trigger search after changing the status
                  widget.onSearch();
                },
              );
            },
          ),
        ),

        const SizedBox(height: 10),
        const SizedBox(height: 10),

        _UserAutocomplete(
          selected: filter.userId,
          users: allUser,
          onChanged: (userId) {
            setState(() {
              ref.read(reportOrderFilterProvider.notifier).setUser(userId);
            });
          },
          onClear: () {
            setState(() {
              ref.read(reportOrderFilterProvider.notifier).setUser(null);
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
                    ref.read(reportOrderFilterProvider.notifier).setFromDate(date);
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
                    ref.read(reportOrderFilterProvider.notifier).setToDate(date);
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

class _ReportOrderCard extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<int> onTap;

  const _ReportOrderCard({
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

    return ReportOrderCard(
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
                      dense: true,
                      minTileHeight: 36,
                      contentPadding: const EdgeInsets.symmetric(horizontal: Constants.listTileFontSize),
                      title: Text(
                        option.name ?? '',
                        style: const TextStyle(fontSize: Constants.listTileFontSize),
                      ),
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