import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';

class ScheduleRepository {
  final Dio _dio = ApiClient.build();

  Future<List<Map<String, dynamic>>> shifts({
    DateTime? from,
    DateTime? to,
    int? userId,
  }) async {
    final r = await _dio.get('/v1/schedule/shifts', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      if (userId != null) 'user_id': userId,
    });
    return (r.data['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> absences({
    DateTime? from,
    DateTime? to,
    int? userId,
  }) async {
    final r = await _dio.get('/v1/schedule/absences', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      if (userId != null) 'user_id': userId,
    });
    return (r.data['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> upsertShift(
    Map<String, dynamic> payload, {
    int? id,
  }) async {
    final res = id == null
        ? await _dio.post('/v1/schedule/shifts', data: payload)
        : await _dio.put('/v1/schedule/shifts/$id', data: payload);
    return Map<String, dynamic>.from(res.data['shift']);
  }

  Future<void> deleteShift(int id) async {
    await _dio.delete('/v1/schedule/shifts/$id');
  }

  Future<Map<String, dynamic>> requestAbsence(
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.post('/v1/schedule/absences', data: payload);
    return Map<String, dynamic>.from(res.data['absence']);
  }

  Future<Map<String, dynamic>> decideAbsence(
    int id,
    String action, {
    String? reason,
  }) async {
    final res = await _dio.post('/v1/schedule/absences/$id/decision', data: {
      'action': action,
      'reason': reason,
    });
    return Map<String, dynamic>.from(res.data['absence']);
  }

  Future<Map<String, dynamic>?> getWorkRules() async {
    final res = await _dio.get('/v1/schedule/work-rules');
    return res.data['rules'];
  }

  Future<Map<String, dynamic>> updateWorkRules(
    Map<String, dynamic> payload,
  ) async {
    final res = await _dio.put('/v1/schedule/work-rules', data: payload);
    return Map<String, dynamic>.from(res.data['rules']);
  }

  Future<String> exportIcs({
    DateTime? from,
    DateTime? to,
    int? userId,
  }) async {
    final res = await _dio.get('/v1/schedule/ics', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      if (userId != null) 'user_id': userId,
    });
    return res.data;
  }
}
