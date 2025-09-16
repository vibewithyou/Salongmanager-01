import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/invoice.dart';
import '../models/cart_item.dart';

class PosRepository {
  final Dio _dio = ApiClient.build();

  Future<void> openSession({double openingCash = 0}) async {
    await _dio.post('/pos/sessions/open', data: {'opening_cash': openingCash});
  }

  Future<Invoice> createInvoice({
    int? customerId,
    required List<CartItem> items,
    Map<String, dynamic>? meta,
  }) async {
    final res = await _dio.post('/pos/invoices', data: {
      'customer_id': customerId,
      'lines': items.map((e) => e.toLine()).toList(),
      'meta': meta ?? {},
    });
    return Invoice.fromJson(Map<String, dynamic>.from(res.data['invoice']));
  }

  Future<void> payInvoice(int invoiceId, {
    required String method,
    required double amount,
  }) async {
    await _dio.post('/pos/invoices/$invoiceId/pay', data: {
      'method': method,
      'amount': amount,
    });
  }

  Future<void> refundInvoice(int invoiceId, {
    required double amount,
    String? reason,
  }) async {
    await _dio.post('/pos/invoices/$invoiceId/refund', data: {
      'amount': amount,
      'reason': reason,
    });
  }

  Future<Map<String, dynamic>> zReport({
    DateTime? from,
    DateTime? to,
  }) async {
    final res = await _dio.get('/pos/reports/z', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<String> downloadDatevCsv({
    DateTime? from,
    DateTime? to,
  }) async {
    final res = await _dio.get('/pos/exports/datev.csv', queryParameters: {
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
    }, options: Options(responseType: ResponseType.plain));
    return res.data.toString();
  }
}