class ReportCustomerFilterState {
  final DateTime? fromDate;
  final DateTime? toDate;

  const ReportCustomerFilterState({
    this.fromDate,
    this.toDate,
  });

  ReportCustomerFilterState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ReportCustomerFilterState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
