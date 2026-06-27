import 'package:flutter/material.dart';

enum OrderStatus {
  // pending(0),
  shipping(1),
  completed(2),
  cancelled(3);

  const OrderStatus(this.value);

  final int value;
}

extension OrderStatusExtension on OrderStatus {
  /// Default status
  static const OrderStatus defaultStatus = OrderStatus.shipping;

  /// Returns Vietnamese label for UI display
  String get label {
    return switch (this) {
      // OrderStatus.pending => 'Đơn mới',
      OrderStatus.shipping => 'Đã lên đơn',
      OrderStatus.completed => 'Đã thanh toán',
      OrderStatus.cancelled => 'Huỷ',
    };
  }

  /// Returns color for UI status badge
  Color? get color {
    return switch (this) {
      // OrderStatus.pending => Colors.blue,
      OrderStatus.shipping => null,  //Colors.amber.shade900
      // OrderStatus.shipping => Color(0xFF3A2E00),  //Colors.amber.shade900
      OrderStatus.completed => Color(0xFF0D3B2A), //Colors.green.shade900
      OrderStatus.cancelled => Color(0xFF3D1A1A), //Colors.red.shade900
    };
  }

  /// Returns icon for UI status display
  IconData get icon {
    return switch (this) {
      // OrderStatus.pending => Icons.add_circle,
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
    return OrderStatus.values.firstWhere(
          (e) => e.value == value,
      orElse: () => defaultStatus,
    );
  }
}