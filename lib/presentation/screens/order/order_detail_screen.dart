import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../core/utilities/date_time_formatter.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order/order_notifier.dart';
import '../../widgets/app_button.dart';
import 'components/order_detail_card.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  ConsumerState<OrderDetailScreen> createState() =>
      _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(orderNotifierProvider.notifier).reload();
    });
  }


  void updateOrder(int id) async {
    final result = await context.push('/order/order-edit/$id');
    if (result == true) {
      ref.read(orderNotifierProvider.notifier).reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderNotifierProvider);

    List<OrderModel> orders = state.allOrder ?? [];

    final Map<int, List<OrderModel>> groupedOrders = {};

    for (final order in orders) {
      groupedOrders.putIfAbsent(order.userId ?? 0, () => []);
      groupedOrders[order.userId ?? 0]!.add(order);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết'),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.padding),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final entry = groupedOrders.entries.elementAt(index);

                  return _UserOrderCardGroup(
                    userId: entry.key,
                    userName: entry.value.first.userName ?? '',
                    orders: entry.value,
                    onTapOrder: updateOrder,
                  );
                },
                childCount: groupedOrders.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _UserOrderCardGroup extends StatelessWidget {
  final int userId;
  final String userName;
  final List<OrderModel> orders;
  final ValueChanged<int> onTapOrder;

  const _UserOrderCardGroup({
    required this.userId,
    required this.userName,
    required this.orders,
    required this.onTapOrder,
  });

  @override
  Widget build(BuildContext context) {
    final userTotal = orders.fold<int>(0,(sum, order) => sum + (order.total ?? 0),);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== HEADER USER =====
            Text(
              userName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),
            // const Divider(),

            // ===== ORDERS LIST =====
            ...orders.map(
                  (order) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _OrderDetailCard(
                  order: order,
                  onTap: onTapOrder,
                ),
              ),
            ),

            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Text.rich(
                  TextSpan(
                    text: "Tổng đơn: ",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.formatVND(userTotal),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderDetailCard extends StatelessWidget {
  final OrderModel order;
  final ValueChanged<int> onTap;

  const _OrderDetailCard({
    required this.order,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OrderDetailCard(
      order: order,
      onTap: () => onTap(order.id!),
    );
  }
}
