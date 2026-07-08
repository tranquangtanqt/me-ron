import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/purchase/purchase_filter_notifier.dart';
import '../../providers/purchase/purchase_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';
import 'components/purchase_card.dart';

class PurchaseScreen extends ConsumerStatefulWidget {
  const PurchaseScreen({super.key});

  @override
  ConsumerState<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends ConsumerState<PurchaseScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(purchaseNotifierProvider.notifier).getAllPurchase(true);
    });
    super.initState();
  }

  void createPurchase() async {
    final result = await context.push('/purchase/purchase-create');
    if (result == true) {
      ref.read(purchaseNotifierProvider.notifier).reload();
    }
  }

  void updatePurchase(int id) async {
    final result = await context.push('/purchase/purchase-edit/$id');
    if (result == true) {
      ref.read(purchaseNotifierProvider.notifier).reload();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ref.listen(purchaseNotifierProvider, (previous, next) {
    //   print("error: ${next.error}");
    //   print("data: ${next.allPurchase}");
    // });

    final allPurchase = ref.watch(purchaseNotifierProvider.select((s) => s.allPurchase));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mua hàng'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          _AddButton(
            onCreate: createPurchase,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(purchaseNotifierProvider.notifier).reload(),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            physics: (allPurchase?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.padding,
                    vertical: 8,
                  ),
                  child: _PurchaseFilterBar(
                    onSearch: () {
                      ref.read(purchaseNotifierProvider.notifier).reload();
                    },
                  ),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, _) {
                  if (allPurchase == null) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppProgressIndicator(),
                    );
                  }

                  if (allPurchase.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppEmptyState(
                        subtitle: 'Hiện tại không có purchase nào, hãy thêm purchase để tiếp tục.',
                        buttonText: 'Thêm',
                        onTapButton: () => createPurchase(),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                    sliver: SliverList.builder(
                      itemCount: allPurchase.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.padding / 2,
                          ),
                          child: PurchaseCard(
                            purchase: allPurchase[i],
                            onTap: () => updatePurchase(allPurchase[i].id!),
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
  const _AddButton({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppSizes.padding),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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

class _PurchaseFilterBar extends ConsumerStatefulWidget {
  final VoidCallback onSearch;
  const _PurchaseFilterBar({required this.onSearch});

  @override
  ConsumerState<_PurchaseFilterBar> createState() => _PurchaseFilterBarState();
}

class _PurchaseFilterBarState extends ConsumerState<_PurchaseFilterBar> with RouteAware {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();

    DateTime now = DateTime.now();
    DateTime fromDate = DateTime(now.year, now.month, now.day, 00, 00, 00, 000);
    DateTime toDate = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);

    final filter = ref.read(purchaseFilterProvider);
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                    ref.read(purchaseFilterProvider.notifier).setFromDate(date);
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
                    ref.read(purchaseFilterProvider.notifier).setToDate(date);
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
