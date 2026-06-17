import 'package:flutter/material.dart';

enum OrderStatus {
  pending(0),
  shipping(1),
  completed(2),
  cancelled(3);

  const OrderStatus(this.value);

  final int value;
}

extension OrderStatusExtension on OrderStatus {
  /// Returns numeric value for database storage
  int get value => index;

  /// Returns Vietnamese label for UI display
  String get label {
    return switch (this) {
      OrderStatus.pending => 'Đơn mới',
      OrderStatus.shipping => 'Đã giao hàng',
      OrderStatus.completed => 'Đã thanh toán',
      OrderStatus.cancelled => 'Huỷ',
    };
  }

  /// Returns color for UI status badge
  Color get color {
    return switch (this) {
      OrderStatus.pending => Colors.blue,
      OrderStatus.shipping => Colors.orange,
      OrderStatus.completed => Colors.green,
      OrderStatus.cancelled => Colors.red,
    };
  }

  /// Returns icon for UI status display
  IconData get icon {
    return switch (this) {
      OrderStatus.pending => Icons.add_circle,
      OrderStatus.shipping => Icons.local_shipping,
      OrderStatus.completed => Icons.check_circle,
      OrderStatus.cancelled => Icons.cancel,
    };
  }

  /// Check if order is in finished state
  bool get isFinished {
    return this == OrderStatus.completed || this == OrderStatus.cancelled;
  }

  /// Check if order is still active
  bool get isActive => !isFinished;

  /// Convert integer value back to OrderStatus enum
  static OrderStatus fromValue(int value) {
    return OrderStatus.values[value];
  }
}