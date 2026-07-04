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

  const OrderItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.products,
    required this.isDisabled,
    required this.onDelete,
    required this.onQuantityChanged,
    required this.onProductChanged,
  });

  @override
  Widget build(BuildContext context) {
    final qty = item.quantity;

    return Opacity(
      opacity: isDisabled ? 0.65 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
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
                    onTap: isDisabled || qty <= 1 ? null : () => onQuantityChanged(qty - 1),
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
                    onTap: isDisabled ? null : () => onQuantityChanged(qty + 1),
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
                onPressed: isDisabled ? null : onDelete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
