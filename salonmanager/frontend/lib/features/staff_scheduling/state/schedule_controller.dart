import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/schedule_repository.dart';
import 'schedule_state.dart';

final scheduleRepositoryProvider = Provider((_) => ScheduleRepository());

final scheduleControllerProvider = StateNotifierProvider<ScheduleController, ScheduleState>(
  (ref) => ScheduleController(ref.read(scheduleRepositoryProvider)),
);

class ScheduleController extends StateNotifier<ScheduleState> {
  final ScheduleRepository _repo;

  ScheduleController(this._repo) : super(ScheduleState());

  Future<void> loadRange(DateTime from, DateTime to, {int? userId}) async {
    state = state.copyWith(loading: true, error: null);
    
    try {
      final shifts = await _repo.shifts(from: from, to: to, userId: userId);
      final absences = await _repo.absences(from: from, to: to, userId: userId);
      
      // Tag events with kind for UI differentiation
      final events = [
        ...shifts.map((e) => ({...e, 'kind': 'shift'})),
        ...absences.map((e) => ({...e, 'kind': 'absence'})),
      ];
      
      state = state.copyWith(loading: false, events: events);
    } catch (e) {
      state = state.copyWith(
        loading: false,
        error: e.toString(),
      );
    }
  }

  void setView(String view) {
    state = state.copyWith(view: view);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  Future<void> createShift(Map<String, dynamic> shiftData) async {
    try {
      await _repo.upsertShift(shiftData);
      // Reload current range
      final from = state.selectedDate.subtract(const Duration(days: 7));
      final to = state.selectedDate.add(const Duration(days: 21));
      await loadRange(from, to);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateShift(int id, Map<String, dynamic> shiftData) async {
    try {
      await _repo.upsertShift(shiftData, id: id);
      // Reload current range
      final from = state.selectedDate.subtract(const Duration(days: 7));
      final to = state.selectedDate.add(const Duration(days: 21));
      await loadRange(from, to);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteShift(int id) async {
    try {
      await _repo.deleteShift(id);
      // Reload current range
      final from = state.selectedDate.subtract(const Duration(days: 7));
      final to = state.selectedDate.add(const Duration(days: 21));
      await loadRange(from, to);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> requestAbsence(Map<String, dynamic> absenceData) async {
    try {
      await _repo.requestAbsence(absenceData);
      // Reload current range
      final from = state.selectedDate.subtract(const Duration(days: 7));
      final to = state.selectedDate.add(const Duration(days: 21));
      await loadRange(from, to);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> decideAbsence(int id, String action, {String? reason}) async {
    try {
      await _repo.decideAbsence(id, action, reason: reason);
      // Reload current range
      final from = state.selectedDate.subtract(const Duration(days: 7));
      final to = state.selectedDate.add(const Duration(days: 21));
      await loadRange(from, to);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
