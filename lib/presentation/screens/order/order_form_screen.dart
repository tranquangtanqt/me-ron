import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../domain/entities/product_entity.dart';
import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
import '../../../core/utilities/currency_formatter.dart';
import '../../../domain/entities/user_entity.dart';
import '../../providers/order/order_form_notifier.dart';
import '../../providers/order/order_notifier.dart';
import '../../providers/products/products_notifier.dart';
import '../../providers/user/user_notifier.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_progress_indicator.dart';
import '../../widgets/app_snack_bar.dart';
import '../../widgets/app_text_field.dart';
import 'components/order_item_form.dart';

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

      deliveryDatetimeController.text =
      state.deliveryDatetime != null
          ? DateFormat('dd/MM/yyyy').format(state.deliveryDatetime!)
          : today;
      noteController.text = state.note ?? '';
      discountValueController.text = state.discountValue?.toString() ?? '';
    });
  }

  @override
  void dispose() {
    deliveryDatetimeController.dispose();
    noteController.dispose();
    discountValueController.dispose();
    super.dispose();
  }

  void createOrder() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).createOrder();
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
      AppSnackBar.show('Thêm mới dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  void updatedOrder() async {
    var res = await AppDialog.showProgress(() {
      return ref.read(orderFormNotifierProvider.notifier).updatedOrder(widget.id!);
    });

    if (res.isSuccess) {
      if (!mounted) return;
      context.pop();
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
      context.pop();
      AppSnackBar.show('Xóa dữ liệu thành công');
    } else {
      AppDialog.showError(error: res.error?.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(orderNotifierProvider, (previous, next) {
      print("error: ${next.error}");
      print("data: ${next.allOrder}");
    });

    final allUser = ref.watch(userNotifierProvider.select((s) => s.allUser)) ?? [];

    final allProduct = ref.watch(productsNotifierProvider.select((s) => s.allProducts)) ?? [];
    
    final notifier = ref.read(orderFormNotifierProvider.notifier);

    final formState = ref.watch(orderFormNotifierProvider);
    final isLoaded = formState.isLoaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Thêm đặt hàng' : 'Chỉnh sửa đặt hàng'),
        titleSpacing: 0,
      ),
      body: !isLoaded
          ? const AppProgressIndicator()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UserAutocomplete(
                    selected: formState.userId,
                    users: allUser,
                    onChanged: notifier.onChangedUser,
                  ),
                  Column(
                    children: [
                      for (var i = 0; i < (formState.items ?? []).length; i++)
                        _OrderItemRow(
                          index: i,
                          item: (formState.items ?? [])[i],
                          products: allProduct,
                          onDelete: () {
                            ref.read(orderFormNotifierProvider.notifier).removeItem(i);
                          },
                          onQuantityChanged: (qty) {
                            ref.read(orderFormNotifierProvider.notifier).updateQuantity(i, qty);
                          },
                          onProductChanged: (product) {
                            ref.read(orderFormNotifierProvider.notifier).updateProduct(i, product);
                          },
                        )
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () {
                      notifier.addItem(
                        allProduct.isNotEmpty ? allProduct.first : null,
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm món'),
                  ),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   children: [
                  //     TextButton.icon(
                  //       onPressed: () {
                  //         notifier.addItem(
                  //           allProduct.isNotEmpty ? allProduct.first : null,
                  //         );
                  //       },
                  //       icon: const Icon(Icons.add),
                  //       label: const Text('Thêm món'),
                  //     ),
                  //
                  //     Container(
                  //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  //       decoration: BoxDecoration(
                  //         color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       // child: Text(
                  //       //   '${CurrencyFormatter.formatVND(formState.total ?? 0)}',
                  //       //   style: const TextStyle(fontWeight: FontWeight.w600),
                  //       // ),
                  //     ),
                  //   ],
                  // ),
                  _DiscountValueField(
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
                  _StatusDropdown(
                    selected: OrderStatusExtension.fromValue(formState.status ?? 0),
                    onChanged: notifier.onChangedStatus,
                  ),
                  _DeliveryDatetimeField(
                    controller: deliveryDatetimeController,
                    onChanged: notifier.onChangedDeliveryDatetime,
                  ),
                  _NoteField(
                    controller: noteController,
                    onChanged: notifier.onChangedNote,
                  ),
                  _CreateOrUpdateButton(
                    id: widget.id,
                    onCreateOrder: createOrder,
                    onUpdatedOrder: updatedOrder,
                  ),
                  _DeleteButton(
                    id: widget.id,
                    onDeleteOrder: deleteOrder,
                  ),
                ],
              ),
            ),
    );
  }
}

class _UserAutocomplete extends StatelessWidget {
  final int? selected;
  final List<UserEntity> users;
  final ValueChanged<int?> onChanged;

  const _UserAutocomplete({
    required this.selected,
    required this.users,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selectedUser = users
        .where((e) => e.id == selected)
        .cast<UserEntity?>()
        .firstOrNull;

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Autocomplete<UserEntity>(
        displayStringForOption: (c) => c.name ?? '',

        optionsBuilder: (TextEditingValue value) {
          final query = value.text.trim().toLowerCase();

          if (query.isEmpty) {
            return users;
          }

          return users.where((c) {
            final deliveryDatetime = (c.name ?? '').toLowerCase();
            return deliveryDatetime.contains(query);
          });
        },

        onSelected: (UserEntity selection) {
          onChanged(selection.id);
        },

        fieldViewBuilder:
            (context, textController, focusNode, onFieldSubmitted) {
          // sync selected text khi edit
          if (selectedUser != null &&
              textController.text.isEmpty) {
            textController.text = selectedUser.name ?? '';
          }

          return SizedBox(
            height: 40,
            child: TextFormField(
              controller: textController,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                labelText: 'Chọn khách hàng',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
          );
        },

        optionsViewBuilder: (context, onSelected, options) {
          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4,
              child: SizedBox(
                height: 220,
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options.elementAt(index);
                    return ListTile(
                      title: Text(option.name ?? ''),
                      onTap: () => onSelected(option),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final OrderStatus? selected;
  final ValueChanged<OrderStatus?> onChanged;

  const _StatusDropdown({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: SizedBox(
        height: 40,
        child: DropdownButtonFormField<OrderStatus>(
          value: selected,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: 'Trạng thái',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: const OutlineInputBorder(),
          ),
          style: const TextStyle(fontSize: 13),

          items: OrderStatus.values.map((status) {
            return DropdownMenuItem<OrderStatus>(
              value: status,
              child: Text(
                status.label,
                style: const TextStyle(fontSize: 13),
              ),
            );
          }).toList(),

          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DeliveryDatetimeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<DateTime> onChanged;

  const _DeliveryDatetimeField({
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
      final formatted = DateFormat('dd/MM/yyyy').format(picked);

      controller.text = formatted;
      onChanged(picked);
      // onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: SizedBox(
        height: 40,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _pickDate(context),
          child: InputDecorator(
            isEmpty: controller.text.isEmpty,
            decoration: InputDecoration(
              labelText: 'Ngày giao hàng',
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              suffixIcon: const Icon(Icons.calendar_month_rounded, size: 18),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_available_rounded,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),

                Expanded(
                  child: Text(
                    controller.text.isEmpty
                        ? 'Chọn ngày'
                        : controller.text,
                    style: TextStyle(
                      fontSize: 13,
                      color: controller.text.isEmpty
                          ? theme.colorScheme.outline
                          : theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscountValueField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DiscountValueField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding / 2),
      child: SizedBox(
        height: 40, // 👈 nhỏ lại (40 → 36)
        child: TextField(
          controller: controller,
          onChanged: onChanged,
          keyboardType: TextInputType.number,
          style: const TextStyle(fontSize: 12.5),

          decoration: InputDecoration(
            isDense: true,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 8,
            ),

            labelText: 'Giảm giá',

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
            ),

            prefixIcon: const Icon(Icons.discount, size: 16),
            suffixIcon: const Icon(Icons.attach_money, size: 16),
          ),
        ),
      ),
    );
  }
}

class _NoteField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NoteField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Ghi chú',
        hintText: 'Nhập ghi chú...',
        maxLines: 4,
        onChanged: onChanged,
      ),
    );
  }
}

class _CreateOrUpdateButton extends ConsumerWidget {
  final int? id;
  final VoidCallback onCreateOrder;
  final VoidCallback onUpdatedOrder;

  const _CreateOrUpdateButton({
    required this.id,
    required this.onCreateOrder,
    required this.onUpdatedOrder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFormValid = ref.watch(
      orderFormNotifierProvider.select((s) {
        debugPrint("userId=${s.userId}, items=${s.items?.length}");
        return s.userId != null && (s.items?.isNotEmpty ?? false);
      }),
    );

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding * 1.5),
      child: AppButton(
        text: id == null ? 'Thêm mới' : 'Chỉnh sửa',
        enabled: isFormValid,
        onTap: () {
          if (id != null) {
            onUpdatedOrder();
          } else {
            onCreateOrder();
          }
        },
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final int? id;
  final VoidCallback onDeleteOrder;

  const _DeleteButton({
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

class _OrderItemRow extends StatelessWidget {
  final int index;
  final OrderItemForm item;
  final List<ProductEntity> products;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<ProductEntity?> onProductChanged;

  const _OrderItemRow({
    required this.index,
    required this.item,
    required this.products,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: DropdownButtonFormField<ProductEntity>(
                value: item.product ?? products.firstOrNull,
                isExpanded: true,
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                style: const TextStyle(fontSize: 13),
                items: products.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(
                      p.name,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  );
                }).toList(),
                onChanged: onProductChanged,
              ),
            ),
          ),

          const SizedBox(width: 6),

          Container(
            height: 32,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  onTap: qty > 1 ? () => onQuantityChanged(qty - 1) : null,
                  child: const SizedBox(
                    width: 28,
                    child: Center(
                      child: Icon(Icons.remove, size: 16),
                    ),
                  ),
                ),

                SizedBox(
                  width: 22,
                  child: Center(
                    child: Text(
                      '$qty',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                InkWell(
                  onTap: () => onQuantityChanged(qty + 1),
                  child: const SizedBox(
                    width: 28,
                    child: Center(
                      child: Icon(Icons.add, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 4),

          SizedBox(
            width: 28,
            height: 28,
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 16,
              splashRadius: 16,
              icon: Icon(
                Icons.close,
                color: Theme.of(context).colorScheme.error,
                size: 16,
              ),
              onPressed: onDelete,
            ),
          )
        ],
      ),
    );

  }
}
