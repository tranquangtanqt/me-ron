import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../providers/order/order_form_notifier.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class OrderCancelButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCancelOrder;

  const OrderCancelButton({
    super.key,
    required this.id,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      orderFormNotifierProvider.select((s) {
        return s.userId != null && (s.items?.isNotEmpty ?? false);
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: AppButton(
        text: 'Hủy đơn',
        enabled: isFormValid,
        onTap: () {
          AppDialog.show(
            title: 'Xác nhận',
            text: 'Bạn có chắc chắn muốn hủy đơn?',
            leftButtonText: 'Không',
            rightButtonText: 'Có',
            rightButtonColor: Theme.of(context).colorScheme.errorContainer,
            rightButtonTextColor: Theme.of(context).colorScheme.error,
            onTapRightButton: (context) async {
              context.pop();
              onCancelOrder();
            },
          );
        },
      ),
    );
  }
}

class OrderDeleteButton extends StatelessWidget {
  final int? id;
  final VoidCallback onDeleteOrder;

  const OrderDeleteButton({
    super.key,
    required this.id,
    required this.onDeleteOrder,
  });

  @override
  Widget build(BuildContext context) {
    if (id == null) return const SizedBox(height: AppSizes.padding * 2);

    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.padding,
        bottom: AppSizes.padding * 2,
      ),
      child: AppButton(
        text: 'Xóa',
        textColor: Theme.of(context).colorScheme.error,
        buttonColor: Theme.of(context).colorScheme.surfaceContainerLowest,
        onTap: () {
          AppDialog.show(
            title: 'Xác nhận',
            text: 'Bạn có chắc chắn muốn xóa dữ liệu?',
            leftButtonText: 'Hủy',
            rightButtonText: 'Xóa',
            rightButtonColor: Theme.of(context).colorScheme.errorContainer,
            rightButtonTextColor: Theme.of(context).colorScheme.error,
            onTapRightButton: (context) async {
              context.pop();
              onDeleteOrder();
            },
          );
        },
      ),
    );
  }
}
