import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../data/models/order_model.dart';
import '../../providers/order/order_form_notifier.dart';
import '../../providers/order/order_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_snack_bar.dart';
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

  // thanh toán
  void onPayment() {
    final allOrder = ref.read(orderNotifierProvider).allOrder;

    bool check = true;
    for (int i = 0; i < allOrder!.length; i++) {
      if (allOrder[i].status == OrderStatus.completed) {
        check = false;
      }
    }

    if (check == false) {
      AppSnackBar.showError('Không cho phép thanh toán với đơn có trạng thái đã thanh toán');
      return;
    }

    // check thanh toán TODO
    final screenContext = context;

    AppDialog.show(
      title: 'Xác nhận',
      text: 'Bạn có chắc chắn muốn Thanh toán toàn bộ?',
      leftButtonText: 'Hủy',
      rightButtonText: 'Thanh toán',
      rightButtonColor: Color(0xFF0D3B2A),
      rightButtonTextColor: Theme.of(context).colorScheme.error,
      onTapRightButton: (context) async {
        //final allOrder = ref.read(orderNotifierProvider).allOrder;

        // updateOrderStatus
        bool successFlg = true;
        for (int i = 0; i < allOrder!.length; i++) {

          var res = await AppDialog.showProgress(() {
            return ref.read(orderFormNotifierProvider.notifier).updatedStatusOrder(allOrder[i].id!, OrderStatus.completed.value);
          });

          if (!screenContext.mounted) return;
          if (!res.isSuccess) {
            successFlg = false;
            AppDialog.showError(error: res.error?.toString());
            break;
          }
        }

        if (!screenContext.mounted) return;

        if (successFlg) {
          try {
            Navigator.of(context, rootNavigator: true).pop();
          } catch (_) {
            // fallback
            Navigator.of(context).pop();
          }

          await Future.delayed(const Duration(milliseconds: 50));

          if (!screenContext.mounted) return;
          GoRouter.of(screenContext).pop(true);

          AppSnackBar.show('Cập nhật dữ liệu thành công');
        }
      },
    );
  }

  // Thanh toán 1 phần (có thể dư hoặc thiếu)
  void onPartialPayment() {
    AppSnackBar.showError('Đang phát triển'); //TODO
    return;
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
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [_PaymentButton(onPayment: onPayment, onPartialPayment: onPartialPayment,)],
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
      backgroundColor: () {
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
        return bg;
      }(),
    );
  }
}

class _PaymentButton extends StatelessWidget {
  final VoidCallback onPayment;
  final VoidCallback onPartialPayment;
  const _PaymentButton({
    required this.onPayment,
    required this.onPartialPayment
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
            onTap: () => onPartialPayment(),
            child: Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.padding / 4),
                Text(
                  'Thanh toán 1 phần',
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
            onTap: () => onPayment(),
            child: Row(
              children: [
                Icon(
                  Icons.payment,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.padding / 4),
                Text(
                  'Thanh toán',
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