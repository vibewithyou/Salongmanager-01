import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';

class PosRepository {
  final Dio _dio = ApiClient.build();

  /// Create a payment session for an invoice
  Future<Map<String, dynamic>> chargeInvoice({
    required int invoiceId,
    required String returnUrl,
    double? amount,
  }) async {
    try {
      final response = await _dio.post(
        '/pos/invoices/$invoiceId/charge',
        data: {
          'return_url': returnUrl,
          if (amount != null) 'amount': amount,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Process a refund for an invoice
  Future<Map<String, dynamic>> refundInvoice({
    required int invoiceId,
    required double amount,
    String? reason,
  }) async {
    try {
      final response = await _dio.post(
        '/pos/invoices/$invoiceId/refund-payment',
        data: {
          'amount': amount,
          if (reason != null) 'reason': reason,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get payment status for an invoice
  Future<Map<String, dynamic>> getPaymentStatus(int invoiceId) async {
    try {
      final response = await _dio.get('/pos/invoices/$invoiceId/payment-status');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get open invoices for POS
  Future<Map<String, dynamic>> getOpenInvoices({
    int? customerId,
    String? from,
    String? to,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'per_page': perPage,
      };

      if (customerId != null) queryParams['customer_id'] = customerId;
      if (from != null) queryParams['from'] = from;
      if (to != null) queryParams['to'] = to;

      final response = await _dio.get(
        '/pos/invoices/open',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Create a new invoice
  Future<Map<String, dynamic>> createInvoice({
    required List<Map<String, dynamic>> lines,
    int? customerId,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final response = await _dio.post(
        '/pos/invoices',
        data: {
          'lines': lines,
          if (customerId != null) 'customer_id': customerId,
          if (meta != null) 'meta': meta,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get invoice details
  Future<Map<String, dynamic>> getInvoice(int invoiceId) async {
    try {
      final response = await _dio.get('/pos/invoices/$invoiceId');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Process a traditional payment (cash, card, etc.)
  Future<Map<String, dynamic>> processPayment({
    required int invoiceId,
    required String method,
    required double amount,
    Map<String, dynamic>? meta,
  }) async {
    try {
      final response = await _dio.post(
        '/pos/invoices/$invoiceId/pay',
        data: {
          'method': method,
          'amount': amount,
          if (meta != null) 'meta': meta,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Process a refund (traditional)
  Future<Map<String, dynamic>> processRefund({
    required int invoiceId,
    required double amount,
    String? reason,
    List<Map<String, dynamic>>? lines,
  }) async {
    try {
      final response = await _dio.post(
        '/pos/invoices/$invoiceId/refund',
        data: {
          'amount': amount,
          if (reason != null) 'reason': reason,
          if (lines != null) 'lines': lines,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get Z-report for POS session
  Future<Map<String, dynamic>> getZReport() async {
    try {
      final response = await _dio.get('/pos/reports/z');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Export DATEV data
  Future<Map<String, dynamic>> exportDatev({
    required String from,
    required String to,
  }) async {
    try {
      final response = await _dio.get(
        '/pos/exports/datev.csv',
        queryParameters: {
          'from': from,
          'to': to,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to appropriate exceptions
  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Connection timeout. Please check your internet connection.');
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        
        if (statusCode == 401) {
          return Exception('Authentication required. Please log in again.');
        } else if (statusCode == 403) {
          return Exception('Access denied. You don\'t have permission to perform this action.');
        } else if (statusCode == 404) {
          return Exception('Resource not found.');
        } else if (statusCode == 422) {
          final message = data?['message'] ?? 'Validation failed.';
          return Exception(message);
        } else if (statusCode == 500) {
          return Exception('Server error. Please try again later.');
        } else {
          final message = data?['message'] ?? 'An error occurred.';
          return Exception(message);
        }
      case DioExceptionType.cancel:
        return Exception('Request was cancelled.');
      case DioExceptionType.unknown:
      default:
        return Exception('An unexpected error occurred. Please try again.');
    }
  }
}