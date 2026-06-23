class OrderFilterState {
  final int? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? userId;

  const OrderFilterState({
    required this.status,
    required this.fromDate,
    required this.toDate,
    this.userId,
  });

  // sentinel used to detect when `userId` was not provided to copyWith
  static const _noUserValue = Object();

  OrderFilterState copyWith({
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
    Object? userId = _noUserValue,
  }) {
    return OrderFilterState(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      userId: identical(userId, _noUserValue) ? this.userId : userId as int?,
    );
  }
}