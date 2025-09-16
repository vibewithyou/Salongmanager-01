import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/customer.dart';
import '../models/customer_profile.dart';
import '../models/customer_note.dart';
import '../models/loyalty.dart';

class CustomerRepository {
  final Dio _dio = ApiClient.build();

  Future<(List<Customer>, int?)> fetchCustomers({String? search, int page = 1}) async {
    final res = await _dio.get('/customers', queryParameters: {
      'search': search,
      'page': page,
    });
    final data = res.data['customers'];
    final list = (data['data'] as List).cast<Map<String, dynamic>>();
    final customers = list.map((j) => Customer.fromJson(j)).toList();
    final next = data['next_page_url'] == null ? null : (page + 1);
    return (customers, next);
  }

  Future<(Customer, CustomerProfile)> fetchCustomer(int id) async {
    final res = await _dio.get('/customers/$id');
    return (
      Customer.fromJson(Map<String, dynamic>.from(res.data['customer'])),
      CustomerProfile.fromJson(Map<String, dynamic>.from(res.data['profile']))
    );
  }

  Future<CustomerProfile> updateProfile(int id, Map<String, dynamic> payload) async {
    final res = await _dio.put('/customers/$id', data: payload);
    return CustomerProfile.fromJson(Map<String, dynamic>.from(res.data['profile']));
  }

  Future<List<CustomerNote>> fetchNotes(int customerId) async {
    final res = await _dio.get('/customers/$customerId/notes');
    final list = (res.data['notes'] as List).cast<Map<String, dynamic>>();
    return list.map((j) => CustomerNote.fromJson(j)).toList();
  }

  Future<CustomerNote> addNote({required int customerId, required String note}) async {
    final res = await _dio.post('/customers/notes', data: {
      'customer_id': customerId,
      'note': note,
    });
    return CustomerNote.fromJson(Map<String, dynamic>.from(res.data['note']));
  }

  Future<(LoyaltyCard, List<LoyaltyTx>)> fetchLoyalty(int customerId) async {
    final res = await _dio.get('/customers/$customerId/loyalty');
    final card = LoyaltyCard.fromJson(Map<String, dynamic>.from(res.data['card']));
    final txs = (res.data['transactions'] as List)
        .map((j) => LoyaltyTx.fromJson(Map<String, dynamic>.from(j)))
        .toList()
        .cast<LoyaltyTx>();
    return (card, txs);
  }

  Future<LoyaltyCard> adjustLoyalty(int customerId, int delta, {String? reason}) async {
    final res = await _dio.post('/customers/$customerId/loyalty/adjust', data: {
      'delta': delta,
      'reason': reason,
    });
    return LoyaltyCard.fromJson(Map<String, dynamic>.from(res.data['card']));
  }
}