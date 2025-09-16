import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../routing/app_router.dart';
import '../../common/ui/sm_toast.dart';

/// Global HTTP error interceptor
class GlobalErrorInterceptor extends Interceptor {
  final Ref _ref;

  GlobalErrorInterceptor(this._ref);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final context = _ref.context;
    final toast = _ref.read(toastControllerProvider.notifier);

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        toast.showError(
          'Verbindung fehlgeschlagen',
          title: 'Netzwerkfehler',
        );
        break;

      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        switch (statusCode) {
          case 401:
            _handleUnauthorized(context);
            break;
          case 403:
            toast.showError(
              'Zugriff verweigert',
              title: 'Berechtigung fehlt',
            );
            break;
          case 404:
            toast.showError(
              'Ressource nicht gefunden',
              title: 'Nicht gefunden',
            );
            break;
          case 409:
            _handleConflict(err, toast);
            break;
          case 422:
            _handleValidationError(err, toast);
            break;
          case 429:
            toast.showWarning(
              'Zu viele Anfragen. Bitte warten Sie einen Moment.',
              title: 'Rate Limit',
            );
            break;
          case 500:
          case 502:
          case 503:
          case 504:
            toast.showError(
              'Serverfehler. Bitte versuchen Sie es später erneut.',
              title: 'Serverfehler',
            );
            break;
          default:
            toast.showError(
              'Ein Fehler ist aufgetreten (${statusCode ?? 'Unbekannt'})',
              title: 'Fehler',
            );
        }
        break;

      case DioExceptionType.cancel:
        // Request was cancelled, don't show error
        break;

      case DioExceptionType.connectionError:
        toast.showError(
          'Keine Internetverbindung',
          title: 'Verbindungsfehler',
        );
        break;

      case DioExceptionType.badCertificate:
        toast.showError(
          'Sicherheitszertifikat ungültig',
          title: 'Sicherheitsfehler',
        );
        break;

      case DioExceptionType.unknown:
      default:
        toast.showError(
          'Ein unbekannter Fehler ist aufgetreten',
          title: 'Fehler',
        );
    }

    handler.next(err);
  }

  void _handleUnauthorized(BuildContext context) {
    final toast = _ref.read(toastControllerProvider.notifier);
    toast.showError(
      'Sitzung abgelaufen. Bitte melden Sie sich erneut an.',
      title: 'Anmeldung erforderlich',
    );
    
    // TODO: Navigate to login page
    // context.go('/login');
  }

  void _handleConflict(DioException err, ToastController toast) {
    final responseData = err.response?.data;
    String message = 'Konflikt aufgetreten';
    
    if (responseData is Map<String, dynamic>) {
      message = responseData['message'] ?? 
                responseData['error'] ?? 
                message;
    }
    
    toast.showWarning(
      message,
      title: 'Konflikt',
    );
  }

  void _handleValidationError(DioException err, ToastController toast) {
    final responseData = err.response?.data;
    String message = 'Validierungsfehler';
    
    if (responseData is Map<String, dynamic>) {
      if (responseData['errors'] is Map<String, dynamic>) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          message = firstError.first.toString();
        }
      } else {
        message = responseData['message'] ?? 
                  responseData['error'] ?? 
                  message;
      }
    }
    
    toast.showError(
      message,
      title: 'Validierungsfehler',
    );
  }
}

/// Loading interceptor to show/hide loading indicators
class LoadingInterceptor extends Interceptor {
  final Ref _ref;
  int _activeRequests = 0;

  LoadingInterceptor(this._ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _activeRequests++;
    _updateLoadingState();
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _activeRequests--;
    _updateLoadingState();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _activeRequests--;
    _updateLoadingState();
    handler.next(err);
  }

  void _updateLoadingState() {
    // TODO: Implement global loading state management
    // This could be used to show/hide a global loading overlay
  }
}

/// Request interceptor for adding common headers
class RequestInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add common headers
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';
    
    // Add authorization header if token exists
    // TODO: Get token from secure storage
    // final token = await getStoredToken();
    // if (token != null) {
    //   options.headers['Authorization'] = 'Bearer $token';
    // }
    
    // Add tenant header if available
    // TODO: Get tenant from context
    // final tenant = getCurrentTenant();
    // if (tenant != null) {
    //   options.headers['X-Tenant-ID'] = tenant;
    // }
    
    handler.next(options);
  }
}

/// Response interceptor for handling common responses
class ResponseInterceptor extends Interceptor {
  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Handle common response patterns
    if (response.data is Map<String, dynamic>) {
      final data = response.data as Map<String, dynamic>;
      
      // Check for API-level errors
      if (data.containsKey('success') && data['success'] == false) {
        final error = DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
          error: data['message'] ?? 'API Error',
        );
        handler.reject(error);
        return;
      }
    }
    
    handler.next(response);
  }
}
