class Movement {
  final int id;
  final int productId;
  final int locationId;
  final String type;
  final int delta;
  final DateTime movedAt;
  final Map<String, dynamic>? meta;

  Movement({
    required this.id,
    required this.productId,
    required this.locationId,
    required this.type,
    required this.delta,
    required this.movedAt,
    this.meta,
  });

  factory Movement.fromJson(Map<String, dynamic> json) => Movement(
    id: json['id'],
    productId: json['product_id'],
    locationId: json['location_id'],
    type: json['type'],
    delta: json['delta'],
    movedAt: DateTime.parse(json['moved_at']),
    meta: json['meta'] != null ? Map<String, dynamic>.from(json['meta']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'location_id': locationId,
    'type': type,
    'delta': delta,
    'moved_at': movedAt.toIso8601String(),
    'meta': meta,
  };
}