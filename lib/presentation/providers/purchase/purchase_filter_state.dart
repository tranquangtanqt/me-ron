class PurchaseFilterState {
  final DateTime? fromDate;
  final DateTime? toDate;

  const PurchaseFilterState({
    required this.fromDate,
    required this.toDate,
  });

  PurchaseFilterState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return PurchaseFilterState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
