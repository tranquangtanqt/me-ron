import 'package:app_image/app_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/themes/app_sizes.dart';
import '../../../../core/utilities/currency_formatter.dart';
import '../../../../data/models/order_model.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final bool enabled;

  const OrderCard({
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
            constraints: const BoxConstraints(
                // maxWidth: 146,
                // maxHeight: 226
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.userName.toString(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    // color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final item in (order.items ?? []))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
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
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 11,
                                // height: 1.3,
                                // color: Colors.blueGrey,
                              ),
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
                const SizedBox(height: 8),
                // Row(
                //   children: [
                //     Icon(
                //       Icons.inventory_2,
                //       size: 8,
                //       color: Theme.of(context).colorScheme.outline,
                //     ),
                //     const SizedBox(width: 4),
                //     Text(
                //       'Stock ${order.total}  |  Sold ${order.total}',
                //       style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 8),
                //     ),
                //   ],
                // ),
                const SizedBox(height: 8),
                Text(
                  "Tổng tiền: ${CurrencyFormatter.formatVND(order.total)}",
                  // textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
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
