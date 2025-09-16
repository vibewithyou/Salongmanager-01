import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../../../core/env/env.dart';
import '../models/user.dart';

class AuthRepository {
  final Dio _dio = ApiClient.build();
  String? _patToken; // persisted via storage in provider

  set patToken(String? token) {
    _patToken = token;
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  Future<void> ensureCsrf() async {
    if (Env.usePat) return;
    // Hit Laravel's native endpoint to set XSRF-TOKEN and session cookies
    await Dio(BaseOptions(
      baseUrl: Env.baseUrl,
      headers: {'X-Salon-Slug': Env.tenantSlug},
    )).get('/sanctum/csrf-cookie');
    // Optional alias: await _dio.get('/auth/csrf');
  }

  Future<void> loginSpa({required String email, required String password}) async {
    await ensureCsrf();
    await _dio.post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<void> logoutSpa() async {
    await _dio.post('/auth/logout');
  }

  Future<String> createPat({required String email, required String password, List<String> scopes = const []}) async {
    final res = await _dio.post('/auth/token', data: {
      'email': email,
      'password': password,
      'scopes': scopes,
    });
    final token = res.data['token'] as String;
    patToken = token;
    return token;
  }

  Future<User?> me() async {
    final res = await _dio.get('/auth/me');
    final userJson = res.data['user'];
    if (userJson == null) return null;
    return User.fromJson(Map<String, dynamic>.from(userJson));
  }
}