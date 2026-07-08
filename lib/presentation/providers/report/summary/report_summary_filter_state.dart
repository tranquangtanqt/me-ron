class ReportSummaryFilterState {
  final DateTime? fromDate;
  final DateTime? toDate;

  const ReportSummaryFilterState({
    required this.fromDate,
    required this.toDate,
  });

  ReportSummaryFilterState copyWith({
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ReportSummaryFilterState(
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}
