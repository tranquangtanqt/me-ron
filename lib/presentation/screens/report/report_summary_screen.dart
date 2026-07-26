import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_sizes.dart';
import '../../providers/report/summary/report_summary_filter_notifier.dart';
import '../../providers/report/summary/report_summary_notifier.dart';
import '../../widgets/app_progress_indicator.dart';

class ReportSummaryScreen extends ConsumerStatefulWidget {
  const ReportSummaryScreen({super.key});

  @override
  ConsumerState<ReportSummaryScreen> createState() => _ReportSummaryScreenState();
}

class _ReportSummaryScreenState extends ConsumerState<ReportSummaryScreen> {
  @override
  Widget build(BuildContext context) {
    final allOrder = ref.watch(reportSummaryNotifierProvider.select((s) => s.allOrder));
    final productSummary = ref.watch(reportSummaryNotifierProvider.select((s) => s.productSummary));
    final allPurchase = ref.watch(reportSummaryNotifierProvider.select((s) => s.allPurchase));
    final purchaseItemSummary = ref.watch(reportSummaryNotifierProvider.select((s) => s.purchaseItemSummary));

    final currencyFormat = NumberFormat('#,###', 'vi_VN');

    final isLoaded = allOrder != null;

    final totalOrderCount = allOrder?.length ?? 0;
    final totalOrderAmount = allOrder?.fold<int>(0, (sum, order) => sum + order.total) ?? 0;

    final totalPurchaseCount = allPurchase?.length ?? 0;
    final totalPurchaseAmount = allPurchase?.fold<int>(0, (sum, purchase) => sum + purchase.total) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng hợp'),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportSummaryNotifierProvider.notifier).reload(),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.padding,
                    vertical: 8,
                  ),
                  child: _ReportSummaryFilterBar(
                    onSearch: () {
                      ref.read(reportSummaryNotifierProvider.notifier).reload();
                    },
                  ),
                ),
              ),
              if (!isLoaded)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  fillOverscroll: true,
                  child: AppProgressIndicator(),
                )
              else ...[
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
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryMetricCard(
                                    title: 'Tổng số đơn',
                                    value: '$totalOrderCount',
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _SummaryMetricCard(
                                    title: 'Tổng thành tiền',
                                    value: '${currencyFormat.format(totalOrderAmount)} đ',
                                    color: Colors.blue,
                                  ),
                                ),
                              ],
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
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tổng số món: ${productSummary.values.fold<int>(0, (s, e) => s + e.quantity)}',
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      (productSummary.values.toList()..sort((a, b) => b.quantity.compareTo(a.quantity)))
                                          .map((e) {
                                            return _SummaryChip(
                                              title: e.productName,
                                              value: '${e.quantity}',
                                              subValue: '${currencyFormat.format(e.totalAmount)} đ',
                                              color: Colors.blue,
                                            );
                                          })
                                          .toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
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
                              'Tổng cộng theo phiếu nhập',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: _SummaryMetricCard(
                                    title: 'Tổng số phiếu',
                                    value: '$totalPurchaseCount',
                                    color: Colors.deepOrange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _SummaryMetricCard(
                                    title: 'Tổng thành tiền',
                                    value: '${currencyFormat.format(totalPurchaseAmount)} đ',
                                    color: Colors.deepOrange,
                                  ),
                                ),
                              ],
                            ),
                            if (purchaseItemSummary != null && purchaseItemSummary.isNotEmpty) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Tổng số mặt hàng: ${purchaseItemSummary.length}',
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                              const SizedBox(height: 10),
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children:
                                      (purchaseItemSummary.values.toList()
                                            ..sort((a, b) => b.totalAmount.compareTo(a.totalAmount)))
                                          .map((e) {
                                            return _SummaryChip(
                                              title: e.itemName,
                                              value: '${currencyFormat.format(e.totalAmount)} đ',
                                              color: Colors.deepOrange,
                                            );
                                          })
                                          .toList(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSizes.padding)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _SummaryMetricCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final String title;
  final String value;
  final String? subValue;
  final Color color;

  const _SummaryChip({
    required this.title,
    required this.value,
    this.subValue,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color),
          ),
          if (subValue != null) ...[
            const SizedBox(height: 2),
            Text(
              subValue!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.blueGrey),
            ),
          ],
        ],
      ),
    );
  }
}

class _ReportSummaryFilterBar extends ConsumerStatefulWidget {
  final VoidCallback onSearch;
  const _ReportSummaryFilterBar({required this.onSearch});

  @override
  ConsumerState<_ReportSummaryFilterBar> createState() => _ReportSummaryFilterBarState();
}

class _ReportSummaryFilterBarState extends ConsumerState<_ReportSummaryFilterBar> {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final filter = ref.read(reportSummaryFilterProvider);

    fromController.text = DateFormat('dd/MM/yyyy').format(filter.fromDate ?? DateTime.now());
    toController.text = DateFormat('dd/MM/yyyy').format(filter.toDate ?? DateTime.now());

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
    return Row(
      children: [
        Expanded(
          child: _DateField(
            label: 'Từ ngày',
            controller: fromController,
            onChanged: (date) {
              ref.read(reportSummaryFilterProvider.notifier).setFromDate(date);
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _DateField(
            label: 'Đến ngày',
            controller: toController,
            onChanged: (date) {
              ref.read(reportSummaryFilterProvider.notifier).setToDate(date);
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 38,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: widget.onSearch,
            child: const Icon(Icons.search, size: 18),
          ),
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
      controller.text = DateFormat('dd/MM/yyyy').format(picked);
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          ),
          child: Text(controller.text.isEmpty ? '' : controller.text),
        ),
      ),
    );
  }
}
