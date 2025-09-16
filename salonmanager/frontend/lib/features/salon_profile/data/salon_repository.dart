import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/salon_profile.dart';
import '../models/content_block.dart';

class SalonRepository {
  final Dio _dio = ApiClient.build();

  Future<SalonProfile> fetchProfile() async {
    final res = await _dio.get('/salon/profile');
    return SalonProfile.fromJson(Map<String, dynamic>.from(res.data['salon']));
  }

  Future<List<ContentBlock>> fetchBlocks() async {
    final res = await _dio.get('/salon/blocks');
    final list = (res.data['blocks'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => ContentBlock.fromJson(j)).toList();
  }

  // Editor stubs (write ops) – only used in admin screens later
  Future<ContentBlock> createBlock(Map<String, dynamic> payload) async {
    final res = await _dio.post('/salon/blocks', data: payload);
    return ContentBlock.fromJson(Map<String, dynamic>.from(res.data['block']));
  }

  Future<ContentBlock> updateBlock(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/salon/blocks/$id', data: payload);
    return ContentBlock.fromJson(Map<String, dynamic>.from(res.data['block']));
  }

  Future<void> deleteBlock(int id) async {
    await _dio.delete('/salon/blocks/$id');
  }
}