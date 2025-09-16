class TopService {
  final String name;
  final int count;
  final double totalRevenue;

  TopService({
    required this.name,
    required this.count,
    required this.totalRevenue,
  });

  factory TopService.fromJson(Map<String, dynamic> json) {
    return TopService(
      name: json['name'] as String,
      count: json['cnt'] as int,
      totalRevenue: (json['total_revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'cnt': count,
      'total_revenue': totalRevenue,
    };
  }
}