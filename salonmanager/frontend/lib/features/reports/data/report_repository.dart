import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';

class ReportRepository {
  final Dio _dio = ApiClient.build();

  Future<List<Map<String, dynamic>>> fetchRevenue(DateTime from, DateTime to) async {
    final res = await _dio.get('/reports/revenue', queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchTopServices(DateTime from, DateTime to) async {
    final res = await _dio.get('/reports/top-services', queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchTopStylists(DateTime from, DateTime to) async {
    final res = await _dio.get('/reports/top-stylists', queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<List<Map<String, dynamic>>> fetchOccupancy(DateTime from, DateTime to) async {
    final res = await _dio.get('/reports/occupancy', queryParameters: {
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return List<Map<String, dynamic>>.from(res.data);
  }

  Future<String> exportCsv(String type, DateTime from, DateTime to) async {
    final res = await _dio.get('/reports/export', queryParameters: {
      'type': type,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
    });
    return res.data;
  }
}