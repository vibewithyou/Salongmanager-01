class SuggestedService {
  final int id;
  final String name;
  final String description;
  final double price;
  final int duration;
  final String? category;
  final double confidence;

  SuggestedService({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.duration,
    this.category,
    required this.confidence,
  });

  factory SuggestedService.fromJson(Map<String, dynamic> json) {
    return SuggestedService(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      duration: json['duration'] ?? 60,
      category: json['category'],
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'duration': duration,
      'category': category,
      'confidence': confidence,
    };
  }
}
