import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../providers/purchase/purchase_form_notifier.dart';
import '../../../widgets/app_button.dart';

class PurchaseFormSaveButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreatePurchase;
  final VoidCallback onUpdatedPurchase;

  const PurchaseFormSaveButton({
    super.key,
    required this.id,
    required this.onCreatePurchase,
    required this.onUpdatedPurchase,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      purchaseFormNotifierProvider.select((s) {
        final items = s.items ?? [];

        if (items.isEmpty) return false;

        return items.every((item) => (item.name?.trim().isNotEmpty ?? false) && item.price > 0);
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
                onUpdatedPurchase();
              } else {
                onCreatePurchase();
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
