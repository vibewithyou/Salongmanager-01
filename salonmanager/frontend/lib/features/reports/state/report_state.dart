import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/revenue_data.dart';
import '../models/top_service.dart';
import '../models/top_stylist.dart';
import '../models/occupancy_data.dart';

class ReportState {
  final List<RevenueData> revenueData;
  final List<TopService> topServices;
  final List<TopStylist> topStylists;
  final List<OccupancyData> occupancyData;
  final bool isLoading;
  final String? error;
  final DateTime? fromDate;
  final DateTime? toDate;

  ReportState({
    this.revenueData = const [],
    this.topServices = const [],
    this.topStylists = const [],
    this.occupancyData = const [],
    this.isLoading = false,
    this.error,
    this.fromDate,
    this.toDate,
  });

  ReportState copyWith({
    List<RevenueData>? revenueData,
    List<TopService>? topServices,
    List<TopStylist>? topStylists,
    List<OccupancyData>? occupancyData,
    bool? isLoading,
    String? error,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return ReportState(
      revenueData: revenueData ?? this.revenueData,
      topServices: topServices ?? this.topServices,
      topStylists: topStylists ?? this.topStylists,
      occupancyData: occupancyData ?? this.occupancyData,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
    );
  }
}