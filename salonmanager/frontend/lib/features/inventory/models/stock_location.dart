class StockLocation {
  final int id;
  final String name;
  final bool isDefault;
  final Map<String, dynamic>? meta;

  StockLocation({
    required this.id,
    required this.name,
    required this.isDefault,
    this.meta,
  });

  factory StockLocation.fromJson(Map<String, dynamic> json) => StockLocation(
    id: json['id'],
    name: json['name'],
    isDefault: json['is_default'] ?? false,
    meta: json['meta'] != null ? Map<String, dynamic>.from(json['meta']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'is_default': isDefault,
    'meta': meta,
  };
}