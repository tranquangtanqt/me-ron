import 'package:flutter/material.dart';

import '../../../../domain/entities/product_entity.dart';
import 'order_item_form.dart';

class OrderItemRow extends StatelessWidget {
  final int index;
  final OrderItemForm item;
  final List<ProductEntity> products;
  final bool isDisabled;
  final VoidCallback onDelete;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<ProductEntity?> onProductChanged;
  final ValueChanged<String> onFreeItemNameChanged;
  final ValueChanged<int> onFreeItemPriceChanged;

  const OrderItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.products,
    required this.isDisabled,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onProductChanged,
    required this.onFreeItemNameChanged,
    required this.onFreeItemPriceChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.65 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: item.isFreeItem ? _buildFreeItemRow(context) : _buildProductItemRow(context),
      ),
    );
  }

  Widget _buildProductItemRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 36,
            child: DropdownButtonFormField<ProductEntity>(
              value: item.product != null && products.contains(item.product) ? item.product : null,
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
              onChanged: isDisabled ? null : onProductChanged,
            ),
          ),
        ),

        const SizedBox(width: 6),

        _QuantityStepper(
          quantity: item.quantity,
          isDisabled: isDisabled,
          onQuantityChanged: onQuantityChanged,
        ),

        const SizedBox(width: 4),

        _DeleteButton(isDisabled: isDisabled, onDelete: onDelete),
      ],
    );
  }

  Widget _buildFreeItemRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 36,
            child: TextFormField(
              initialValue: item.freeItemName,
              enabled: !isDisabled,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Tên món',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: onFreeItemNameChanged,
            ),
          ),
        ),

        const SizedBox(width: 6),

        Expanded(
          flex: 2,
          child: SizedBox(
            height: 36,
            child: TextFormField(
              initialValue: item.freeItemPrice == null || item.freeItemPrice == 0 ? '' : item.freeItemPrice.toString(),
              enabled: !isDisabled,
              keyboardType: TextInputType.number,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                isDense: true,
                hintText: 'Đơn giá',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 6,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              onChanged: (value) => onFreeItemPriceChanged(int.tryParse(value) ?? 0),
            ),
          ),
        ),

        const SizedBox(width: 6),

        _QuantityStepper(
          quantity: item.quantity,
          isDisabled: isDisabled,
          onQuantityChanged: onQuantityChanged,
        ),

        const SizedBox(width: 4),

        _DeleteButton(isDisabled: isDisabled, onDelete: onDelete),
      ],
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final bool isDisabled;
  final ValueChanged<int> onQuantityChanged;

  const _QuantityStepper({
    required this.quantity,
    required this.isDisabled,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
            onTap: isDisabled || quantity <= 1 ? null : () => onQuantityChanged(quantity - 1),
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
                '$quantity',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          InkWell(
            onTap: isDisabled ? null : () => onQuantityChanged(quantity + 1),
            child: const SizedBox(
              width: 28,
              child: Center(
                child: Icon(Icons.add, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  final bool isDisabled;
  final VoidCallback onDelete;

  const _DeleteButton({
    required this.isDisabled,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
        onPressed: isDisabled ? null : onDelete,
      ),
    );
  }
}
