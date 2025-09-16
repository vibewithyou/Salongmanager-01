class Service {
  final int id;
  final String name;
  final String? description;
  final int baseDuration; // minutes
  final double basePrice;

  const Service({
    required this.id,
    required this.name,
    this.description,
    required this.baseDuration,
    required this.basePrice,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      baseDuration: json['base_duration'] as int,
      basePrice: (json['base_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'base_duration': baseDuration,
      'base_price': basePrice,
    };
  }
}