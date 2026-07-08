import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../providers/purchase/purchase_form_notifier.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import 'components/purchase_date_field.dart';
import 'components/purchase_delete_button.dart';
import 'components/purchase_form_save_button.dart';
import 'components/purchase_item_row.dart';

class PurchaseFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const PurchaseFormScreen({
    super.key,
    this.id,
  });

  @override
  ConsumerState<PurchaseFormScreen> createState() => _PurchaseFormScreenState();
}

class _PurchaseFormScreenState extends ConsumerState<PurchaseFormScreen> {
  final dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(purchaseFormNotifierProvider.notifier).initPurchaseForm(widget.id);

      final state = ref.read(purchaseFormNotifierProvider);

      final date = state.date ?? DateTime.now();
      dateController.text = DateFormat('dd/MM/yyyy').format(date);
    });
  }

  @override
  void dispose() {
    dateController.dispose();
    super.dispose();
  }

  void createPurchase() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(purchaseFormNotifierProvider.notifier).createPurchase();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Thêm mới dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updatedPurchase() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(purchaseFormNotifierProvider.notifier).updatedPurchase(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Cập nhật dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deletePurchase() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(purchaseFormNotifierProvider.notifier).deletePurchase(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Xóa dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(purchaseFormNotifierProvider.notifier);

    final formState = ref.watch(purchaseFormNotifierProvider);
    final isLoaded = formState.isLoaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Thêm phiếu nhập' : 'Chỉnh sửa phiếu nhập'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          PurchaseFormSaveButton(
            id: widget.id,
            onCreatePurchase: createPurchase,
            onUpdatedPurchase: updatedPurchase,
          ),
        ],
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PurchaseDateField(
                    label: 'Ngày nhập',
                    controller: dateController,
                    onChanged: notifier.onChangedDate,
                  ),

                  const SizedBox(height: AppSizes.padding),

                  Column(
                    children: List.generate(
                      formState.items?.length ?? 0,
                      (i) {
                        final item = formState.items![i];

                        return PurchaseItemRow(
                          index: i,
                          item: item,
                          onNameChanged: (name) => notifier.updateItemName(i, name),
                          onPriceChanged: (price) => notifier.updateItemPrice(i, price),
                          onDelete: () => notifier.removeItem(i),
                        );
                      },
                    ),
                  ),

                  TextButton.icon(
                    onPressed: notifier.addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm hàng'),
                  ),

                  const SizedBox(height: AppSizes.padding / 2),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Tổng: ${CurrencyFormatter.formatVND(formState.total ?? 0)}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),

                  PurchaseDeleteButton(
                    id: widget.id,
                    onDeletePurchase: deletePurchase,
                  ),
                ],
              ),
            ),
    );
  }
}
