import 'package:dio/dio.dart';
import '../../core/env/env.dart';

class ApiClient {
  static Dio build() {
    final dio = Dio(BaseOptions(
      baseUrl: '${Env.baseUrl}/api/v1',
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'X-Salon-Slug': Env.tenantSlug, // tenant binding
      },
      // For SPA cookie flow, ensure with browser that credentials are allowed (handled by browser).
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // CSRF: for SPA cookie flow, backend expects X-XSRF-TOKEN header. In browser, Dio can't read httpOnly cookies.
        // Strategy: call /sanctum/csrf-cookie once on app start via fetch (JS) or provide an endpoint /v1/auth/csrf.
        // Here we assume frontend first calls AuthRepository.ensureCsrf() before login.
        handler.next(options);
      },
      onError: (e, handler) {
        // TODO: add 401 handling (token refresh / redirect login)
        handler.next(e);
      },
    ));
    return dio;
  }
}