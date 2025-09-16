class RevenueData {
  final String day;
  final double revenue;

  RevenueData({
    required this.day,
    required this.revenue,
  });

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      day: json['day'] as String,
      revenue: (json['revenue'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'revenue': revenue,
    };
  }
}