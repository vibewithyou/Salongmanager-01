class TopStylist {
  final String name;
  final int count;
  final double totalRevenue;

  TopStylist({
    required this.name,
    required this.count,
    required this.totalRevenue,
  });

  factory TopStylist.fromJson(Map<String, dynamic> json) {
    return TopStylist(
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