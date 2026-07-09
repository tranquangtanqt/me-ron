class AutoExportState {
  final int? hour;
  final int? minute;
  final bool isAllowed;

  const AutoExportState({this.hour, this.minute, this.isAllowed = false});

  bool get isConfigured => hour != null && minute != null;

  AutoExportState copyWith({int? hour, int? minute, bool? isAllowed}) {
    return AutoExportState(
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      isAllowed: isAllowed ?? this.isAllowed,
    );
  }
}
