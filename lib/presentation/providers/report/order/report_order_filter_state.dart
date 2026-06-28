class ReportOrderFilterState {
  final int? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? userId;

  const ReportOrderFilterState({
    required this.status,
    required this.fromDate,
    required this.toDate,
    this.userId,
  });

  // sentinel user to detect when `userId` was not provided to copyWith
  static const _noUserValue = Object();

  ReportOrderFilterState copyWith({
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
    Object? userId = _noUserValue,
  }) {
    return ReportOrderFilterState(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      userId: identical(userId, _noUserValue) ? this.userId : userId as int?,
    );
  }
}