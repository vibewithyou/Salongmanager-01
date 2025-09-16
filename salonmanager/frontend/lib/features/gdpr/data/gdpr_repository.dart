import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';

class GdprRepository {
  final Dio _dio = ApiClient.build();

  /// Request data export
  Future<Map<String, dynamic>> export() async {
    try {
      final response = await _dio.post('/v1/gdpr/export');
      return Map<String, dynamic>.from(response.data['file']);
    } on DioException catch (e) {
      throw Exception('Failed to export data: ${e.message}');
    }
  }

  /// Request account deletion
  Future<void> requestDelete() async {
    try {
      await _dio.post('/v1/gdpr/delete');
    } on DioException catch (e) {
      throw Exception('Failed to request deletion: ${e.message}');
    }
  }

  /// Confirm deletion request (Admin only)
  Future<void> confirmDelete(int requestId) async {
    try {
      await _dio.post('/v1/gdpr/delete/$requestId/confirm');
    } on DioException catch (e) {
      throw Exception('Failed to confirm deletion: ${e.message}');
    }
  }
}