class ScheduleState {
  final bool loading;
  final List<Map<String, dynamic>> events; // shifts expanded + absences with type/status
  final String? error;
  final String view; // 'day', 'week', 'month'
  final DateTime selectedDate;

  ScheduleState({
    this.loading = false,
    this.events = const [],
    this.error,
    this.view = 'week',
    DateTime? selectedDate,
  }) : selectedDate = selectedDate ?? DateTime.now();

  ScheduleState copyWith({
    bool? loading,
    List<Map<String, dynamic>>? events,
    String? error,
    String? view,
    DateTime? selectedDate,
  }) {
    return ScheduleState(
      loading: loading ?? this.loading,
      events: events ?? this.events,
      error: error,
      view: view ?? this.view,
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}
