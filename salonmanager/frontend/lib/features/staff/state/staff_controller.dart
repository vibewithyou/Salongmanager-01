import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/staff_repository.dart';
import 'staff_state.dart';

final staffRepositoryProvider = Provider<StaffRepository>((ref) => StaffRepository());

DateTime _startOfWeek(DateTime d) => d.subtract(Duration(days: (d.weekday % 7)));
DateTime _endOfWeek(DateTime d) => _startOfWeek(d).add(const Duration(days: 7));

final staffControllerProvider = StateNotifierProvider<StaffController, StaffState>((ref) {
  final now = DateTime.now();
  return StaffController(
    ref.watch(staffRepositoryProvider),
    StaffState(rangeFrom: _startOfWeek(now), rangeTo: _endOfWeek(now)),
  );
});

class StaffController extends StateNotifier<StaffState> {
  final StaffRepository _repo;

  StaffController(this._repo, StaffState initial) : super(initial) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    try {
      final shifts = await _repo.fetchShifts(
        from: state.rangeFrom,
        to: state.rangeTo,
        stylistId: state.filterStylistId,
      );
      final abs = await _repo.fetchAbsences(stylistId: state.filterStylistId);
      state = state.copyWith(shifts: shifts, absences: abs);
    } finally {
      state = state.copyWith(loading: false);
    }
  }

  void setView(String view) => state = state.copyWith(view: view);

  void setRange(DateTime from, DateTime to) {
    state = state.copyWith(rangeFrom: from, rangeTo: to);
    refresh();
  }

  void setStylistFilter(int? id) {
    state = state.copyWith(filterStylistId: id);
    refresh();
  }

  Future<void> createShift(Map<String, dynamic> data) async {
    await _repo.createShift(data);
    refresh();
  }

  Future<void> updateShift(int id, Map<String, dynamic> data) async {
    await _repo.updateShift(id, data);
    refresh();
  }

  Future<void> deleteShift(int id) async {
    await _repo.deleteShift(id);
    refresh();
  }

  Future<void> moveShift(int id, DateTime startAt, DateTime endAt) async {
    await _repo.moveShift(id, startAt: startAt, endAt: endAt);
    refresh();
  }

  Future<void> resizeShift(int id, DateTime endAt) async {
    await _repo.resizeShift(id, endAt: endAt);
    refresh();
  }

  Future<void> createAbsence(Map<String, dynamic> data) async {
    await _repo.createAbsence(data);
    refresh();
  }

  Future<void> updateAbsence(int id, Map<String, dynamic> data) async {
    await _repo.updateAbsence(id, data);
    refresh();
  }

  Future<void> deleteAbsence(int id) async {
    await _repo.deleteAbsence(id);
    refresh();
  }

  Future<void> approveAbsence(int id) async {
    await _repo.approveAbsence(id);
    refresh();
  }
}