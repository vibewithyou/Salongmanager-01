import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/shift.dart';
import '../models/absence.dart';

class StaffRepository {
  final Dio _dio = ApiClient.build();

  Future<List<Shift>> fetchShifts({
    DateTime? from,
    DateTime? to,
    int? stylistId,
  }) async {
    final res = await _dio.get('/staff/shifts', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      if (stylistId != null) 'stylist_id': stylistId,
    });
    final list = (res.data['shifts'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => Shift.fromJson(j)).toList();
  }

  Future<Shift> createShift(Map<String, dynamic> payload) async {
    final res = await _dio.post('/staff/shifts', data: payload);
    return Shift.fromJson(Map<String, dynamic>.from(res.data['shift']));
  }

  Future<Shift> updateShift(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/staff/shifts/$id', data: payload);
    return Shift.fromJson(Map<String, dynamic>.from(res.data['shift']));
  }

  Future<void> deleteShift(int id) async {
    await _dio.delete('/staff/shifts/$id');
  }

  Future<Shift> moveShift(int id, {
    required DateTime startAt,
    required DateTime endAt,
  }) async {
    final res = await _dio.post('/staff/shifts/$id/move', data: {
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
    });
    return Shift.fromJson(Map<String, dynamic>.from(res.data['shift']));
  }

  Future<Shift> resizeShift(int id, {required DateTime endAt}) async {
    final res = await _dio.post('/staff/shifts/$id/resize', data: {
      'end_at': endAt.toIso8601String(),
    });
    return Shift.fromJson(Map<String, dynamic>.from(res.data['shift']));
  }

  Future<List<Absence>> fetchAbsences({int? stylistId}) async {
    final res = await _dio.get('/staff/absences', queryParameters: {
      if (stylistId != null) 'stylist_id': stylistId,
    });
    final list = (res.data['absences'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => Absence.fromJson(j)).toList();
  }

  Future<Absence> createAbsence(Map<String, dynamic> payload) async {
    final res = await _dio.post('/staff/absences', data: payload);
    return Absence.fromJson(Map<String, dynamic>.from(res.data['absence']));
  }

  Future<Absence> updateAbsence(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/staff/absences/$id', data: payload);
    return Absence.fromJson(Map<String, dynamic>.from(res.data['absence']));
  }

  Future<void> deleteAbsence(int id) async {
    await _dio.delete('/staff/absences/$id');
  }

  Future<Absence> approveAbsence(int id) async {
    final res = await _dio.post('/staff/absences/$id/approve');
    return Absence.fromJson(Map<String, dynamic>.from(res.data['absence']));
  }
}