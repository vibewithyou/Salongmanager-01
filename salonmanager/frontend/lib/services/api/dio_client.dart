import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
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

    // Add retry interceptor
    dio.interceptors.add(RetryInterceptor());

    // Add offline detection interceptor
    dio.interceptors.add(OfflineInterceptor());

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

/// Retry interceptor with exponential backoff
class RetryInterceptor extends Interceptor {
  static const int maxRetries = 3;
  static const Duration baseDelay = Duration(milliseconds: 500);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (_shouldRetry(err)) {
      final retryCount = err.requestOptions.extra['retry_count'] ?? 0;
      
      if (retryCount < maxRetries) {
        final delay = Duration(
          milliseconds: baseDelay.inMilliseconds * (1 << retryCount),
        );
        
        debugPrint('Retrying request after ${delay.inMilliseconds}ms (attempt ${retryCount + 1}/$maxRetries)');
        
        await Future.delayed(delay);
        
        final options = err.requestOptions.copyWith(
          extra: {...err.requestOptions.extra, 'retry_count': retryCount + 1},
        );
        
        try {
          final response = await Dio().fetch(options);
          handler.resolve(response);
          return;
        } catch (e) {
          // Continue to next retry or fail
        }
      }
    }
    
    handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    // Retry on 5xx errors and network issues
    return err.type == DioExceptionType.connectionTimeout ||
           err.type == DioExceptionType.sendTimeout ||
           err.type == DioExceptionType.receiveTimeout ||
           err.type == DioExceptionType.connectionError ||
           (err.response?.statusCode != null && err.response!.statusCode! >= 500);
  }
}

/// Offline detection interceptor
class OfflineInterceptor extends Interceptor {
  static bool _isOffline = false;
  static final List<VoidCallback> _offlineListeners = [];

  static bool get isOffline => _isOffline;
  
  static void addOfflineListener(VoidCallback listener) {
    _offlineListeners.add(listener);
  }
  
  static void removeOfflineListener(VoidCallback listener) {
    _offlineListeners.remove(listener);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final wasOffline = _isOffline;
    
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      _isOffline = true;
      
      if (!wasOffline) {
        debugPrint('Network offline detected');
        for (final listener in _offlineListeners) {
          listener();
        }
      }
    } else if (_isOffline && err.response?.statusCode != null) {
      // Got a response, we're back online
      _isOffline = false;
      debugPrint('Network back online');
    }
    
    handler.next(err);
  }
}