import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../widgets/app_button.dart';
import '../../../widgets/app_dialog.dart';

class PurchaseDeleteButton extends StatelessWidget {
  final int? id;
  final VoidCallback onDeletePurchase;

  const PurchaseDeleteButton({
    super.key,
    required this.id,
    required this.onDeletePurchase,
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
              onDeletePurchase();
            },
          );
        },
      ),
    );
  }
}
