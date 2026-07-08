import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/utilities/currency_formatter.dart';
import '../../../../data/models/purchase_item_model.dart';
import '../../../../data/models/purchase_model.dart';

class PurchaseCard extends StatelessWidget {
  final PurchaseModel purchase;
  final VoidCallback? onTap;

  const PurchaseCard({
    super.key,
    required this.purchase,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(purchase.date);

    return RepaintBoundary(
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black.withValues(alpha: 0.06),
        splashFactory: InkRipple.splashFactory,
        highlightColor: Colors.black12,
        borderRadius: BorderRadius.circular(4),
        child: Ink(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 0.5,
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date != null ? DateFormat('dd/MM/yyyy').format(date) : purchase.date,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              for (PurchaseItemModel item in (purchase.items ?? []))
                Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 4,
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          item.name ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                        ),
                      ),
                      Text(
                        CurrencyFormatter.formatVND(item.price ?? 0),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 4),

              Align(
                alignment: Alignment.centerRight,
                child: Text.rich(
                  TextSpan(
                    text: 'Tổng: ',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: CurrencyFormatter.formatVND(purchase.total),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
