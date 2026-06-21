import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../data/models/order_item_model.dart';
import '../../../../data/models/order_model.dart';

class OrderDetailCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final bool enabled;

  const OrderDetailCard({
    super.key,
    required this.order,
    this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: InkWell(
        onTap: enabled ? onTap : null,
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
          child: ConstrainedBox(
            constraints: const BoxConstraints(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      order.deliveryDatetime != null
                          ? DateFormat('dd/MM/yyyy').format(order.deliveryDatetime!)
                          : '',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (OrderItemModel item in (order.items ?? []))
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

                            // Name
                            Expanded(
                              flex: 3,
                              child: Text(
                                  item.snapshotName ?? '',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontSize: 11,
                                  // height: 1.3,
                                ),
                              ),
                            ),

                            // Price
                            Text(
                              CurrencyFormatter.formatVND(item.snapshotPrice ?? 0),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11),
                            ),

                            const SizedBox(width: 12),

                            // Quantity
                            Text(
                              'x${item.quantity}',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                // height: 1.3,
                                fontWeight: FontWeight.normal,
                              ),
                            ),

                            const SizedBox(width: 20),

                            // Line total
                            Text(
                              CurrencyFormatter.formatVND(item.lineTotal ?? 0),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                // height: 1.3,
                                fontWeight: FontWeight.normal,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Divider(
                          thickness: 0.8,
                          height: 0,
                          color: Theme.of(context)
                              .colorScheme
                              .outline
                              .withValues(alpha: 0.3),
                        ),

                        Text(
                          CurrencyFormatter.formatVND(order.total),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OutOfStock extends StatelessWidget {
  const _OutOfStock();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        padding: const EdgeInsets.all(6),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(
            vertical: AppSizes.padding / 4,
            horizontal: AppSizes.padding / 2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.remove_circle,
                color: Theme.of(context).colorScheme.outline,
                size: 10,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  'Out of stock',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.bold,
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
