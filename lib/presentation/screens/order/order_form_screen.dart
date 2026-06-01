import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_pos/domain/entities/product_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/order_status.dart';
import '../../../core/themes/app_sizes.dart';
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
      final today = "${now.day.toString().padLeft(2, '0')}/"
          "${now.month.toString().padLeft(2, '0')}/"
          "${now.year}";

      deliveryDatetimeController.text =
          state.deliveryDatetime ?? today;
      noteController.text = state.note ?? '';
    });
  }

  @override
  void dispose() {
    deliveryDatetimeController.dispose();
    noteController.dispose();
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

    final formState = ref.watch(orderFormNotifierProvider);

    final allUser = ref.watch(userNotifierProvider.select((s) => s.allUser)) ?? [];
    // final state = ref.watch(userNotifierProvider);
    // print(state.allUser);

    final allProduct = ref.watch(productsNotifierProvider.select((s) => s.allProducts)) ?? [];
    
    final notifier = ref.read(orderFormNotifierProvider.notifier);

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
                        )
                    ],
                  ),
                  TextButton.icon(
                    onPressed: notifier.addItem,
                    icon: const Icon(Icons.add),
                    label: const Text('Thêm món'),
                  ),
                  _StatusDropdown(
                    selected: OrderStatusExtension.fromValue(formState.status ?? 0),
                    onChanged: notifier.onChangedStatus,
                  ),
                  _DeliveryDatetimeField(
                    controller: deliveryDatetimeController,
                    onChanged: notifier.onChangedDeliveryDatetime,
                  ),
                  // _PriceField(
                  //   controller: priceController,
                  //   onChanged: notifier.onChangedPrice,
                  // ),
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
      padding: const EdgeInsets.only(top: 16),
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

          return TextFormField(
            controller: textController, // ✅ dùng controller của Autocomplete
            focusNode: focusNode,
            decoration: const InputDecoration(
              labelText: 'Chọn khách hàng',
              border: OutlineInputBorder(),
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
      child: DropdownButtonFormField<OrderStatus>(
        value: selected,
        decoration: const InputDecoration(
          labelText: 'Trạng thái',
          border: OutlineInputBorder(),
        ),
        isExpanded: true,

        items: OrderStatus.values.map((status) {
          return DropdownMenuItem<OrderStatus>(
            value: status,
            child: Text(status.label),
          );
        }).toList(),

        onChanged: onChanged,
      ),
    );
  }
}

class _DeliveryDatetimeField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _DeliveryDatetimeField({
    required this.controller,
    required this.onChanged,
  });

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formatted =
          "${picked.day.toString().padLeft(2, '0')}/"
          "${picked.month.toString().padLeft(2, '0')}/"
          "${picked.year}";

      controller.text = formatted;
      onChanged(formatted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _pickDate(context),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Ngày giao hàng',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            suffixIcon: const Icon(Icons.calendar_month_rounded),
          ),
          child: Row(
            children: [
              Icon(
                Icons.event_available_rounded,
                size: 18,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  controller.text.isEmpty
                      ? 'Chọn ngày giao hàng'
                      : controller.text,
                  style: controller.text.isEmpty
                      ? theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.outline,
                  )
                      : theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriceField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _PriceField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSizes.padding),
      child: AppTextField(
        controller: controller,
        labelText: 'Giá bán',
        hintText: 'Nhập giá bán...',
        type: AppTextFieldType.currency,
        onChanged: onChanged,
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

  const _OrderItemRow({
    required this.index,
    required this.item,
    required this.products,
    required this.onDelete,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // PRODUCT
          Expanded(
            flex: 3,
            child: DropdownButtonFormField<ProductEntity>(
              value: item.product ?? products.firstOrNull,
              isExpanded: true,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding:
                EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                border: OutlineInputBorder(),
              ),
              items: products.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text(
                    p.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: (value) {
                // update product
              },
            ),
          ),

          const SizedBox(width: 8),

          // QTY STEPPER
          Container(
            height: 40,
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                // MINUS
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30),
                  icon: const Icon(Icons.remove, size: 18),
                  onPressed: qty > 1
                      ? () => onQuantityChanged(qty - 1)
                      : null,
                ),

                Text(
                  qty.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),

                // PLUS
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 30),
                  icon: const Icon(Icons.add, size: 18),
                  onPressed: () => onQuantityChanged(qty + 1),
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // DELETE
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            icon: Icon(
              Icons.close,
              size: 20,
              color: Theme.of(context).colorScheme.error,
            ),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}