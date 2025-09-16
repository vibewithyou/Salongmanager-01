// Dio client setup with placeholder interceptor for auth token
// Base URL is provided via --dart-define=API_BASE_URL

import 'package:dio/dio.dart';

class DioClient {
  DioClient._internal();
  static final DioClient instance = DioClient._internal();

  late final Dio dio = _createDio();

  Dio _createDio() {
    final baseUrl = const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:8000/api/v1');
    final options = BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
      },
    );
    final dio = Dio(options);

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // TODO: inject auth token from secure storage when available
        // options.headers['Authorization'] = 'Bearer <token>';
        return handler.next(options);
      },
      onError: (e, handler) {
        // Basic logging/error mapping placeholder
        return handler.next(e);
      },
    ));

    return dio;
  }
}

