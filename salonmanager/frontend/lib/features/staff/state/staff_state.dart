import '../models/shift.dart';
import '../models/absence.dart';

class StaffState {
  final bool loading;
  final List<Shift> shifts;
  final List<Absence> absences;
  final DateTime rangeFrom;
  final DateTime rangeTo;
  final int? filterStylistId;
  final String view; // 'day' | 'week' | 'month'

  const StaffState({
    this.loading = false,
    this.shifts = const [],
    this.absences = const [],
    required this.rangeFrom,
    required this.rangeTo,
    this.filterStylistId,
    this.view = 'week',
  });

  StaffState copyWith({
    bool? loading,
    List<Shift>? shifts,
    List<Absence>? absences,
    DateTime? rangeFrom,
    DateTime? rangeTo,
    int? filterStylistId,
    String? view,
  }) =>
      StaffState(
        loading: loading ?? this.loading,
        shifts: shifts ?? this.shifts,
        absences: absences ?? this.absences,
        rangeFrom: rangeFrom ?? this.rangeFrom,
        rangeTo: rangeTo ?? this.rangeTo,
        filterStylistId: filterStylistId ?? this.filterStylistId,
        view: view ?? this.view,
      );
}