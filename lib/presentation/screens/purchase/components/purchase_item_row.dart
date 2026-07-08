import 'package:flutter/material.dart';

import 'purchase_item_form.dart';

class PurchaseItemRow extends StatelessWidget {
  final int index;
  final PurchaseItemForm item;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onPriceChanged;
  final VoidCallback onDelete;

  const PurchaseItemRow({
    super.key,
    required this.index,
    required this.item,
    required this.onNameChanged,
    required this.onPriceChanged,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                initialValue: item.name,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Tên hàng',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: onNameChanged,
              ),
            ),
          ),

          const SizedBox(width: 6),

          Expanded(
            flex: 2,
            child: SizedBox(
              height: 36,
              child: TextFormField(
                initialValue: item.price == 0 ? '' : item.price.toString(),
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  isDense: true,
                  hintText: 'Giá',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                ),
                style: const TextStyle(fontSize: 13),
                onChanged: (value) => onPriceChanged(int.tryParse(value) ?? 0),
              ),
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
          ),
        ],
      ),
    );
  }
}
