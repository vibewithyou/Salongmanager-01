class SalonProfile {
  final int id;
  final String name;
  final String slug;
  final String? logoPath;
  final String? primaryColor;
  final String? secondaryColor;
  final Map<String, dynamic> brand;
  final Map<String, dynamic> seo;
  final Map<String, dynamic> social;
  final Map<String, dynamic> contentSettings;

  SalonProfile({
    required this.id,
    required this.name,
    required this.slug,
    this.logoPath,
    this.primaryColor,
    this.secondaryColor,
    this.brand = const {},
    this.seo = const {},
    this.social = const {},
    this.contentSettings = const {},
  });

  factory SalonProfile.fromJson(Map<String, dynamic> j) => SalonProfile(
    id: j['id'] as int,
    name: j['name'] ?? '',
    slug: j['slug'] ?? '',
    logoPath: j['logo_path'],
    primaryColor: j['primary_color'],
    secondaryColor: j['secondary_color'],
    brand: Map<String,dynamic>.from(j['brand'] ?? {}),
    seo: Map<String,dynamic>.from(j['seo'] ?? {}),
    social: Map<String,dynamic>.from(j['social'] ?? {}),
    contentSettings: Map<String,dynamic>.from(j['content_settings'] ?? {}),
  );
}