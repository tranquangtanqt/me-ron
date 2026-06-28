import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../data/models/order_model.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/category/category_notifier.dart';
import '../../providers/products/products_notifier.dart';
import '../../providers/report/product/report_product_filter_notifier.dart';
import '../../providers/report/product/report_product_notifier.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/report_product_card.dart';

class ReportProductScreen extends ConsumerStatefulWidget {
  const ReportProductScreen({super.key});

  @override
  ConsumerState<ReportProductScreen> createState() => _ReportProductScreenState();
}

class _ReportProductScreenState extends ConsumerState<ReportProductScreen> {
  List<CategoryEntity> allCategory = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryNotifierProvider.notifier).getAllCategory();
      ref.read(productsNotifierProvider.notifier).getAllProducts();
    });
    super.initState();
  }

  void updateOrder(int id) async {
    final result = await context.push('/order/order-edit/$id');
    if (result == true) {
      ref.read(reportProductNotifierProvider.notifier).reloadByReportProduct();
    }
  }

  void toDetailOrder() async {
    final result = await context.push('/order/order-detail');
    if (result == true) {
      ref.read(reportProductNotifierProvider.notifier).reloadByReportProduct();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    final allOrder = ref.watch(reportProductNotifierProvider.select((s) => s.allOrder));
    final summary = ref.watch(reportProductNotifierProvider.select((s) => s.productSummary));

    print(summary?.values.toList());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Thống kê theo món ăn'),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportProductNotifierProvider.notifier).reloadByReportProduct(),
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
                  child: _ReportProductFilterBar(onSearch: () {
                    ref.read(reportProductNotifierProvider.notifier).reloadByReportProduct();
                  })
                ),
              ),
              if (summary != null && summary.isNotEmpty)
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
                              'Tổng số món: ${summary.values.fold<int>(0, (s, e) => s + e.quantity)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                                color: Colors.blueGrey,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // LIST
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: (summary.values.toList()
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
                                'Danh sách chi tiết',
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
                              return _ReportProductCard(
                                order: allOrder[i],
                                onTap: updateOrder,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );

                  // return SliverPadding(
                  //   padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                  //   sliver: SliverList.builder(
                  //     itemCount: allOrder.length,
                  //     itemBuilder: (context, i) {
                  //       return Padding(
                  //         padding: const EdgeInsets.only(
                  //           bottom: AppSizes.padding / 2,
                  //         ),
                  //         child: _ReportProductCard(
                  //             order: allOrder[i],
                  //             onTap: updateOrder
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReportProductFilterBar extends ConsumerStatefulWidget {
  final VoidCallback onSearch;
  const _ReportProductFilterBar({required this.onSearch});

  @override
  ConsumerState<_ReportProductFilterBar> createState() => _ReportProductFilterBarState();
}

class _ReportProductFilterBarState extends ConsumerState<_ReportProductFilterBar> with RouteAware {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day, 00, 00, 00, 000);
    DateTime toDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final filter = ref.read(reportProductFilterProvider);
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
    final allProduct = ref.watch(productsNotifierProvider.select((s) => s.allProducts)) ?? [];

    final filter = ref.watch(reportProductFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ===== CHIPS FILTER =====
        const SizedBox(height: 10),

        _ProductAutocomplete(
          selected: filter.productId,
          products: allProduct,
          onChanged: (productId) {
            setState(() {
              ref.read(reportProductFilterProvider.notifier).setProduct(productId);
            });
          },
          onClear: () {
            setState(() {
              ref.read(reportProductFilterProvider.notifier).setProduct(null);
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
                    ref.read(reportProductFilterProvider.notifier).setFromDate(date);
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
                    ref.read(reportProductFilterProvider.notifier).setToDate(date);
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

class _ReportProductCard extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<int> onTap;

  const _ReportProductCard({
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

    return ReportProductCard(
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

class _ProductAutocomplete extends StatelessWidget {
  final int? selected;
  final List<ProductEntity> products;
  final ValueChanged<int?> onChanged;
  final VoidCallback onClear;

  const _ProductAutocomplete({
    super.key,
    required this.selected,
    required this.products,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Autocomplete<ProductEntity>(
        displayStringForOption: (u) => u.name ?? '',

        optionsBuilder: (TextEditingValue value) {
          final query = value.text.trim().toLowerCase();

          if (query.isEmpty) return products;

          return products.where(
                (u) => (u.name ?? '').toLowerCase().contains(query),
          );
        },

        onSelected: (ProductEntity user) {
          FocusScope.of(context).unfocus();
          onChanged(user.id);
        },

        fieldViewBuilder:(context, textController, focusNode, onFieldSubmitted) {
          final selectedUser = selected == null
              ? null
              : products.where((u) => u.id == selected).firstOrNull;

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
                labelText: 'Chọn món ăn',
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