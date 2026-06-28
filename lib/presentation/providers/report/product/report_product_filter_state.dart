class ReportProductFilterState {
  final int? status;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? productId;

  const ReportProductFilterState({
    required this.status,
    required this.fromDate,
    required this.toDate,
    this.productId,
  });

  // sentinel product to detect when `productId` was not provided to copyWith
  static const _noUserValue = Object();

  ReportProductFilterState copyWith({
    int? status,
    DateTime? fromDate,
    DateTime? toDate,
    Object? productId = _noUserValue,
  }) {
    return ReportProductFilterState(
      status: status ?? this.status,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      productId: identical(productId, _noUserValue) ? this.productId : productId as int?,
    );
  }
}