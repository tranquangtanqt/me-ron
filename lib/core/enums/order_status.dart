enum OrderStatus {
  // pending,
  // confirmed,
  // preparing,
  shipping,
  completed,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  int get value => index;

  String get label {
    switch (this) {
      // case OrderStatus.pending:
      //   return 'Mới tạo';
      //   return 'Pending';

      // case OrderStatus.confirmed:
      //   return 'Đã xác nhận';
      //   return 'Confirmed';
      //
      // case OrderStatus.preparing:
      //   return 'Đang chuẩn bị';
      //   // return 'Preparing';
      //
      case OrderStatus.shipping:
        return 'Đang giao';
        return 'Shipping';

      case OrderStatus.completed:
        return 'Đã thanh toán';
        return 'Completed';

      case OrderStatus.cancelled:
        return 'Huỷ';
    }
  }

  bool get isFinished {
    return this == OrderStatus.completed ||
        this == OrderStatus.cancelled;
  }

  bool get isActive {
    return !isFinished;
  }

  static OrderStatus fromValue(int value) {
    return OrderStatus.values[value];
  }
}