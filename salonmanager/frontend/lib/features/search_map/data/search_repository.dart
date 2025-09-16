import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/salon_hit.dart';
import '../models/slot.dart';

class SearchRepository {
  final Dio _dio = ApiClient.build();

  Future<({List<SalonHit> hits, int? nextPage})> searchSalons({
    String? q, 
    double? lat, 
    double? lng, 
    double? radiusKm, 
    int? serviceId, 
    bool openNow = false,
    int page = 1, 
    int perPage = 20, 
    String sort = 'distance'
  }) async {
    final res = await _dio.get('/search/salons', queryParameters: {
      if (q != null && q.isNotEmpty) 'q': q,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (radiusKm != null) 'radius_km': radiusKm,
      if (serviceId != null) 'service_id': serviceId,
      if (openNow) 'open_now': true,
      'page': page, 
      'per_page': perPage, 
      'sort': sort,
    });
    final items = (res.data['items'] as List)
        .map((j) => SalonHit.fromJson(Map<String,dynamic>.from(j)))
        .toList()
        .cast<SalonHit>();
    final next = res.data['pagination']['next_page'] as int?;
    return (hits: items, nextPage: next);
  }

  Future<List<Slot>> availability({
    required int salonId, 
    required int serviceId, 
    DateTime? from, 
    DateTime? to, 
    int limit = 3
  }) async {
    final res = await _dio.get('/search/availability', queryParameters: {
      'salon_id': salonId, 
      'service_id': serviceId,
      if (from != null) 'from': from.toIso8601String(),
      if (to != null) 'to': to.toIso8601String(),
      'limit': limit,
    });
    final list = (res.data['slots'] as List)
        .map((j) => Slot.fromJson(Map<String,dynamic>.from(j)))
        .toList()
        .cast<Slot>();
    return list;
  }
}