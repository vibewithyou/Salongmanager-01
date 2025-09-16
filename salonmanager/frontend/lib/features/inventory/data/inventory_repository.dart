import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/product.dart';
import '../models/stock_item.dart';
import '../models/movement.dart';
import '../models/supplier.dart';
import '../models/stock_location.dart';

class InventoryRepository {
  final Dio _dio = ApiClient.build();

  // Products
  Future<({List<Product> items, int? nextPage})> fetchProducts({String? search, int page = 1}) async {
    final res = await _dio.get('/inventory/products', queryParameters: {
      'search': search,
      'page': page,
    });
    final data = res.data['products'];
    final list = (data['data'] as List)
        .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final next = data['next_page_url'] == null ? null : page + 1;
    return (items: list, nextPage: next);
  }

  Future<void> upsertProduct(Map<String, dynamic> payload, {int? id}) async {
    if (id == null) {
      await _dio.post('/inventory/products', data: payload);
    } else {
      await _dio.put('/inventory/products/$id', data: payload);
    }
  }

  // Stock management
  Future<({List<StockItem> items, int? nextPage})> fetchStock({int page = 1}) async {
    final res = await _dio.get('/inventory/stock', queryParameters: {'page': page});
    final data = res.data['items'];
    final list = (data['data'] as List)
        .map((e) => StockItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final next = data['next_page_url'] == null ? null : page + 1;
    return (items: list, nextPage: next);
  }

  Future<List<Map<String, dynamic>>> lowStock() async {
    final res = await _dio.get('/inventory/stock/low');
    return (res.data['items'] as List).cast<Map<String, dynamic>>();
  }

  Future<void> inbound({
    required int productId,
    required int locationId,
    required int qty,
    String? note,
  }) async {
    await _dio.post('/inventory/stock/in', data: {
      'product_id': productId,
      'location_id': locationId,
      'qty': qty,
      'note': note,
    });
  }

  Future<void> outbound({
    required int productId,
    required int locationId,
    required int qty,
    String? note,
  }) async {
    await _dio.post('/inventory/stock/out', data: {
      'product_id': productId,
      'location_id': locationId,
      'qty': qty,
      'note': note,
    });
  }

  Future<void> transfer({
    required int productId,
    required int fromLocationId,
    required int toLocationId,
    required int qty,
    String? note,
  }) async {
    await _dio.post('/inventory/stock/transfer', data: {
      'product_id': productId,
      'from_location_id': fromLocationId,
      'to_location_id': toLocationId,
      'qty': qty,
      'note': note,
    });
  }

  Future<({List<Movement> items, int? nextPage})> movements({int? productId, int page = 1}) async {
    final res = await _dio.get('/inventory/stock/movements', queryParameters: {
      'product_id': productId,
      'page': page,
    });
    final data = res.data['movements'];
    final list = (data['data'] as List)
        .map((e) => Movement.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final next = data['next_page_url'] == null ? null : page + 1;
    return (items: list, nextPage: next);
  }

  // Suppliers
  Future<({List<Supplier> items, int? nextPage})> fetchSuppliers({int page = 1}) async {
    final res = await _dio.get('/inventory/suppliers', queryParameters: {'page': page});
    final data = res.data['suppliers'];
    final list = (data['data'] as List)
        .map((e) => Supplier.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    final next = data['next_page_url'] == null ? null : page + 1;
    return (items: list, nextPage: next);
  }

  Future<void> upsertSupplier(Map<String, dynamic> payload, {int? id}) async {
    if (id == null) {
      await _dio.post('/inventory/suppliers', data: payload);
    } else {
      await _dio.put('/inventory/suppliers/$id', data: payload);
    }
  }

  // Stock locations
  Future<List<StockLocation>> fetchLocations() async {
    final res = await _dio.get('/inventory/locations');
    return (res.data['locations'] as List)
        .map((e) => StockLocation.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> upsertLocation(Map<String, dynamic> payload, {int? id}) async {
    if (id == null) {
      await _dio.post('/inventory/locations', data: payload);
    } else {
      await _dio.put('/inventory/locations/$id', data: payload);
    }
  }
}