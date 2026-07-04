import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../providers/order/order_form_notifier.dart';
import '../../../widgets/app_button.dart';

class OrderFormSaveButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreateOrder;
  final VoidCallback onUpdatedOrder;

  const OrderFormSaveButton({
    super.key,
    required this.id,
    required this.onCreateOrder,
    required this.onUpdatedOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      orderFormNotifierProvider.select((s) {
        return s.userId != null && (s.items?.isNotEmpty ?? false);
      }),
    );

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
            onTap: () {
              if (id != null) {
                onUpdatedOrder();
              } else {
                onCreateOrder();
              }
            },
            enabled: isFormValid,
            child: Row(
              children: [
                Icon(
                  Icons.save,
                  size: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSizes.padding / 4),
                Text(
                  'Lưu',
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
