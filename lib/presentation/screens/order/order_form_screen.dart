import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../providers/order/order_form_notifier.dart';
import '../../providers/products/products_notifier.dart';
import '../../providers/user/user_notifier.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_user_autocomplete.dart';
import 'components/order_date_field.dart';
import 'components/order_form_action_buttons.dart';
import 'components/order_form_fields.dart';
import 'components/order_form_save_button.dart';
import 'components/order_item_row.dart';
import 'components/order_voice_add_button.dart';

class OrderFormScreen extends ConsumerStatefulWidget {
  final int? id;

  const OrderFormScreen({
    super.key,
    this.id,
  });

  @override
  ConsumerState<OrderFormScreen> createState() => _OrderFormScreenState();
}

class _OrderFormScreenState extends ConsumerState<OrderFormScreen> {
  final deliveryDatetimeController = TextEditingController();
  final paymentDatetimeController = TextEditingController();
  final discountValueController = TextEditingController();
  final noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(orderFormNotifierProvider.notifier).initOrderForm(widget.id);

      ref.read(userNotifierProvider.notifier).getAllUser();
      ref.read(productsNotifierProvider.notifier).getAllProducts();

      final state = ref.read(orderFormNotifierProvider);

      final now = DateTime.now();
      final today = DateFormat('dd/MM/yyyy').format(now);

      deliveryDatetimeController.text = state.deliveryDatetime != null
          ? DateFormat('dd/MM/yyyy').format(state.deliveryDatetime!)
          : today;
      paymentDatetimeController.text = state.paymentDatetime != null
          ? DateFormat('dd/MM/yyyy').format(state.paymentDatetime!)
          : today;
      noteController.text = state.note ?? '';
      discountValueController.text = state.discountValue?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    deliveryDatetimeController.dispose();
    paymentDatetimeController.dispose();
    noteController.dispose();
    discountValueController.dispose();
    super.dispose();
  }

  Future<bool> _confirmDuplicateOrder() async {
    final result = await AppDialog.show(
      title: 'Cảnh báo trùng đơn',
      text: 'Khách hàng này đã có đơn đặt hàng trong ngày hôm nay. Bạn có chắc chắn muốn tiếp tục lưu đơn này?',
      leftButtonText: 'Hủy',
      rightButtonText: 'Vẫn lưu',
      onTapLeftButton: (context) => Navigator.of(context).pop(false),
      onTapRightButton: (context) => Navigator.of(context).pop(true),
    );

    return result == true;
  }

  void createOrder() async {
    final hasDuplicate = await ref.read(orderFormNotifierProvider.notifier).hasOrderTodayForUser();

    if (hasDuplicate) {
      final confirmed = await _confirmDuplicateOrder();
      if (!confirmed) return;
    }

    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).createOrder();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Thêm mới dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updatedOrder() async {
    final hasDuplicate = await ref
        .read(orderFormNotifierProvider.notifier)
        .hasOrderTodayForUser(excludeOrderId: widget.id);

    if (hasDuplicate) {
      final confirmed = await _confirmDuplicateOrder();
      if (!confirmed) return;
    }

    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).updatedOrder(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Cập nhật dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void deleteOrder() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).deleteOrder(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Xóa dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void cancelOrder() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).updatedStatusOrder(widget.id!, OrderStatus.cancelled.value);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop(true);
      AppSnackBar.show('Hủy đơn thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUser = ref.watch(userNotifierProvider.select((s) => s.allUser)) ?? [];

    final allProduct = ref.watch(productsNotifierProvider.select((s) => s.allProducts)) ?? [];

    final notifier = ref.read(orderFormNotifierProvider.notifier);

    final formState = ref.watch(orderFormNotifierProvider);
    final isLoaded = formState.isLoaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Thêm đặt hàng' : 'Chỉnh sửa đặt hàng'),
        elevation: 0,
        shadowColor: Colors.transparent,
        actions: [
          OrderFormSaveButton(
            id: widget.id,
            onCreateOrder: createOrder,
            onUpdatedOrder: updatedOrder,
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
                  AppUserAutocomplete(
                    selected: formState.userId,
                    users: allUser,
                    onChanged: notifier.onChangedUser,
                    onClear: notifier.onClear,
                  ),
                  Column(
                    children: [
                      Column(
                        children: List.generate(
                          formState.items?.length ?? 0,
                          (i) {
                            final item = formState.items![i];

                            final isPriceChanged =
                                widget.id != null &&
                                item.snapshotPrice != null &&
                                item.product != null &&
                                item.originalProductId != null &&
                                item.product!.id == item.originalProductId &&
                                item.snapshotPrice != item.product!.price;

                            return OrderItemRow(
                              key: ValueKey(item.localKey),
                              index: i,
                              item: item,
                              products: allProduct,
                              isDisabled: isPriceChanged,
                              onDelete: () {
                                ref.read(orderFormNotifierProvider.notifier).removeItem(i);
                              },
                              onQuantityChanged: (qty) {
                                ref.read(orderFormNotifierProvider.notifier).updateQuantity(i, qty);
                              },
                              onProductChanged: (product) {
                                ref.read(orderFormNotifierProvider.notifier).updateProduct(i, product);
                              },
                              onFreeItemNameChanged: (name) {
                                ref.read(orderFormNotifierProvider.notifier).updateFreeItemName(i, name);
                              },
                              onFreeItemPriceChanged: (price) {
                                ref.read(orderFormNotifierProvider.notifier).updateFreeItemPrice(i, price);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          notifier.addItem(
                            allProduct.isNotEmpty ? allProduct.first : null,
                          );
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Thêm món'),
                      ),
                      TextButton.icon(
                        onPressed: notifier.addFreeItem,
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Thêm món tự do'),
                      ),

                      OrderVoiceAddButton(products: allProduct),
                    ],
                  ),
                  OrderDiscountValueField(
                    controller: discountValueController,
                    onChanged: notifier.onChangedDiscountValue,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                  ),
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
                  OrderDateField(
                    label: 'Ngày giao hàng',
                    controller: deliveryDatetimeController,
                    onChanged: notifier.onChangedDeliveryDatetime,
                  ),
                  OrderPrepaidCheckbox(
                    value: formState.isPrepaid,
                    onChanged: notifier.onChangedPrepaid,
                  ),
                  if (formState.isPrepaid)
                    OrderDateField(
                      label: 'Ngày thanh toán',
                      topPadding: 2,
                      controller: paymentDatetimeController,
                      onChanged: notifier.onChangedPaymentDatetime,
                    ),
                  OrderNoteField(
                    controller: noteController,
                    onChanged: notifier.onChangedNote,
                  ),
                  if (widget.id != null && formState.status != OrderStatus.cancelled.value)
                    OrderCancelButton(
                      id: widget.id,
                      onCancelOrder: cancelOrder,
                    ),
                  OrderDeleteButton(
                    id: widget.id,
                    onDeleteOrder: deleteOrder,
                  ),
                ],
              ),
            ),
    );
  }
}
