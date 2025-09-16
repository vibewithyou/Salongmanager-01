import '../models/salon_hit.dart';

class SearchState {
  final bool loading;
  final List<SalonHit> hits;
  final int? nextPage;
  final String query;
  final double? lat, lng, radiusKm;
  final int? serviceId;
  final bool openNow;

  const SearchState({
    this.loading = false,
    this.hits = const [],
    this.nextPage = 1,
    this.query = '',
    this.lat, 
    this.lng, 
    this.radiusKm = 5,
    this.serviceId, 
    this.openNow = false,
  });

  SearchState copyWith({
    bool? loading, 
    List<SalonHit>? hits, 
    int? nextPage, 
    String? query,
    double? lat, 
    double? lng, 
    double? radiusKm, 
    int? serviceId, 
    bool? openNow,
  }) => SearchState(
    loading: loading ?? this.loading,
    hits: hits ?? this.hits,
    nextPage: nextPage,
    query: query ?? this.query,
    lat: lat ?? this.lat,
    lng: lng ?? this.lng,
    radiusKm: radiusKm ?? this.radiusKm,
    serviceId: serviceId ?? this.serviceId,
    openNow: openNow ?? this.openNow,
  );
}