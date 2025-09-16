import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/report_repository.dart';
import '../models/revenue_data.dart';
import '../models/top_service.dart';
import '../models/top_stylist.dart';
import '../models/occupancy_data.dart';
import 'report_state.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository();
});

final reportControllerProvider = StateNotifierProvider<ReportController, ReportState>((ref) {
  return ReportController(ref.read(reportRepositoryProvider));
});

class ReportController extends StateNotifier<ReportState> {
  final ReportRepository _repository;

  ReportController(this._repository) : super(ReportState());

  Future<void> loadReports(DateTime from, DateTime to) async {
    state = state.copyWith(isLoading: true, error: null, fromDate: from, toDate: to);
    
    try {
      final results = await Future.wait([
        _repository.fetchRevenue(from, to),
        _repository.fetchTopServices(from, to),
        _repository.fetchTopStylists(from, to),
        _repository.fetchOccupancy(from, to),
      ]);

      final revenueData = results[0].map((json) => RevenueData.fromJson(json)).toList();
      final topServices = results[1].map((json) => TopService.fromJson(json)).toList();
      final topStylists = results[2].map((json) => TopStylist.fromJson(json)).toList();
      final occupancyData = results[3].map((json) => OccupancyData.fromJson(json)).toList();

      state = state.copyWith(
        revenueData: revenueData,
        topServices: topServices,
        topStylists: topStylists,
        occupancyData: occupancyData,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> exportCsv(String type) async {
    if (state.fromDate == null || state.toDate == null) return;
    
    try {
      await _repository.exportCsv(type, state.fromDate!, state.toDate!);
    } catch (e) {
      state = state.copyWith(error: 'Export failed: ${e.toString()}');
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}