import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';

class NotifyRepository {
  final Dio _dio = ApiClient.build();

  Future<List<Map<String,dynamic>>> prefs() async {
    final r = await _dio.get('/notify/prefs');
    return (r.data['items'] as List).cast<Map<String,dynamic>>();
  }

  Future<void> updatePrefs(List<Map<String,dynamic>> items) async {
    await _dio.post('/notify/prefs', data: {'items': items});
  }

  Future<List<Map<String,dynamic>>> webhooks() async {
    final r = await _dio.get('/notify/webhooks');
    return (r.data['items'] as List).cast<Map<String,dynamic>>();
  }

  Future<void> upsertWebhook(Map<String,dynamic> payload, {int? id}) async {
    if (id == null) await _dio.post('/notify/webhooks', data: payload);
    else await _dio.put('/notify/webhooks/$id', data: payload);
  }

  Future<void> deleteWebhook(int id) async {
    await _dio.delete('/notify/webhooks/$id');
  }
}