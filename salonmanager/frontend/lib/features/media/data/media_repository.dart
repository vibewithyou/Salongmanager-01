import 'dart:io';
import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';

class MediaRepository {
  final Dio _api = ApiClient.build();

  Future<({String key, Uri uploadUrl, Map<String, String> headers})> initiate({
    required String filename,
    required String mime,
    required int bytes,
    String visibility = 'internal',
    bool consentRequired = false,
    int? subjectUserId,
    String? subjectName,
    String? subjectContact,
  }) async {
    final res = await _api.post('/media/uploads/initiate', data: {
      'filename': filename,
      'mime': mime,
      'bytes': bytes,
      'visibility': visibility,
      'consent_required': consentRequired,
      'subject_user_id': subjectUserId,
      'subject_name': subjectName,
      'subject_contact': subjectContact,
    });

    return (
      key: res.data['key'] as String,
      uploadUrl: Uri.parse(res.data['upload_url'] as String),
      headers: Map<String, String>.from(res.data['headers'] as Map)
    );
  }

  Future<Map<String, dynamic>> finalize({
    required String key,
    required String mime,
    required int bytes,
    required String ownerType,
    required int ownerId,
    String visibility = 'internal',
    bool consentRequired = false,
    int? subjectUserId,
    String? subjectName,
    String? subjectContact,
    int? width,
    int? height,
  }) async {
    final res = await _api.post('/media/uploads/finalize', data: {
      'key': key,
      'mime': mime,
      'bytes': bytes,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'visibility': visibility,
      'consent_required': consentRequired,
      'subject_user_id': subjectUserId,
      'subject_name': subjectName,
      'subject_contact': subjectContact,
      'width': width,
      'height': height,
    });

    return Map<String, dynamic>.from(res.data['file']);
  }

  Future<void> uploadPut(
    Uri url,
    File file, {
    required String contentType,
    Map<String, String>? headers,
    void Function(int, int)? onProgress,
  }) async {
    final dio = Dio();
    await dio.putUri(
      url,
      data: file.openRead(),
      options: Options(
        headers: {
          'Content-Type': contentType,
          ...(headers ?? {}),
        },
      ),
      onSendProgress: onProgress,
    );
  }

  Future<Map<String, dynamic>> getFile(int fileId) async {
    final res = await _api.get('/media/files/$fileId');
    return Map<String, dynamic>.from(res.data['file']);
  }

  Future<void> deleteFile(int fileId) async {
    await _api.delete('/media/files/$fileId');
  }
}