class SalonHit {
  final int id;
  final String name;
  final String slug;
  final String? logoPath;
  final String? shortDesc;
  final String? city;
  final String? zip;
  final double lat;
  final double lng;
  final double? distanceKm;

  SalonHit({
    required this.id, 
    required this.name, 
    required this.slug,
    this.logoPath, 
    this.shortDesc, 
    this.city, 
    this.zip,
    required this.lat, 
    required this.lng, 
    this.distanceKm,
  });

  factory SalonHit.fromJson(Map<String,dynamic> j) => SalonHit(
    id: j['id'] as int,
    name: j['name'] ?? '',
    slug: j['slug'] ?? '',
    logoPath: j['logo_path'],
    shortDesc: j['short_desc'],
    city: j['city'],
    zip: j['zip'],
    lat: (j['lat'] as num).toDouble(),
    lng: (j['lng'] as num).toDouble(),
    distanceKm: (j['distance_km'] as num?)?.toDouble(),
  );
}