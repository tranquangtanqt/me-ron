import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../data/models/customer_summary_model.dart';
import '../../providers/report/customer/report_customer_filter_notifier.dart';
import '../../providers/report/customer/report_customer_notifier.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/app_progress_indicator.dart';

class ReportCustomerScreen extends ConsumerStatefulWidget {
  const ReportCustomerScreen({super.key});

  @override
  ConsumerState<ReportCustomerScreen> createState() => _ReportCustomerScreenState();
}

class _ReportCustomerScreenState extends ConsumerState<ReportCustomerScreen> {
  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(reportCustomerNotifierProvider.select((s) => s.customers));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Theo khách hàng tiềm năng'),
        elevation: 0,
        shadowColor: Colors.transparent,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(reportCustomerNotifierProvider.notifier).reload(),
        displacement: 60,
        child: Scrollbar(
          child: CustomScrollView(
            physics: (customers?.isEmpty ?? true) ? const NeverScrollableScrollPhysics() : null,
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSizes.padding,
                    vertical: 8,
                  ),
                  child: _ReportCustomerFilterBar(
                    onSearch: () {
                      ref.read(reportCustomerNotifierProvider.notifier).reload();
                    },
                  ),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, _) {
                  if (customers == null) {
                    return const SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppProgressIndicator(),
                    );
                  }

                  if (customers.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      fillOverscroll: true,
                      child: AppEmptyState(
                        subtitle: 'Không có dữ liệu khách hàng trong khoảng thời gian đã chọn.',
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(AppSizes.padding, 2, AppSizes.padding, AppSizes.padding),
                    sliver: SliverList.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSizes.padding / 2),
                          child: _CustomerRankCard(rank: i + 1, customer: customers[i]),
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

class _ReportCustomerFilterBar extends ConsumerStatefulWidget {
  final VoidCallback onSearch;
  const _ReportCustomerFilterBar({required this.onSearch});

  @override
  ConsumerState<_ReportCustomerFilterBar> createState() => _ReportCustomerFilterBarState();
}

class _ReportCustomerFilterBarState extends ConsumerState<_ReportCustomerFilterBar> {
  final fromController = TextEditingController();
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();

    final filter = ref.read(reportCustomerFilterProvider);

    if (filter.fromDate != null) {
      fromController.text = DateFormat('dd/MM/yyyy').format(filter.fromDate!);
    }
    if (filter.toDate != null) {
      toController.text = DateFormat('dd/MM/yyyy').format(filter.toDate!);
    }

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
    final filter = ref.watch(reportCustomerFilterProvider);
    final hasDateFilter = filter.fromDate != null || filter.toDate != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _DateField(
                label: 'Từ ngày',
                controller: fromController,
                onChanged: (date) {
                  setState(() {
                    ref.read(reportCustomerFilterProvider.notifier).setFromDate(date);
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
                    ref.read(reportCustomerFilterProvider.notifier).setToDate(date);
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
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

        const SizedBox(height: 6),

        if (hasDateFilter)
          GestureDetector(
            onTap: () {
              setState(() {
                fromController.clear();
                toController.clear();
                ref.read(reportCustomerFilterProvider.notifier).clearDates();
              });
              widget.onSearch();
            },
            child: Text(
              'Bỏ lọc ngày (xem toàn bộ)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                decoration: TextDecoration.underline,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          )
        else
          Text(
            'Đang xem toàn bộ thời gian',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
      ],
    );
  }
}

class _CustomerRankCard extends StatelessWidget {
  final int rank;
  final CustomerSummaryModel customer;

  const _CustomerRankCard({
    required this.rank,
    required this.customer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          width: 0.5,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  customer.userName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${customer.orderCount} đơn',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            CurrencyFormatter.formatVND(customer.totalAmount),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: Text(
            controller.text.isEmpty ? '' : controller.text,
          ),
        ),
      ),
    );
  }
}
