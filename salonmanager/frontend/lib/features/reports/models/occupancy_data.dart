class OccupancyData {
  final String day;
  final int totalMinutes;
  final int bookedMinutes;
  final double occupancyPercentage;

  OccupancyData({
    required this.day,
    required this.totalMinutes,
    required this.bookedMinutes,
    required this.occupancyPercentage,
  });

  factory OccupancyData.fromJson(Map<String, dynamic> json) {
    return OccupancyData(
      day: json['day'] as String,
      totalMinutes: json['total_minutes'] as int,
      bookedMinutes: json['booked_minutes'] as int,
      occupancyPercentage: (json['occupancy_percentage'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'total_minutes': totalMinutes,
      'booked_minutes': bookedMinutes,
      'occupancy_percentage': occupancyPercentage,
    };
  }
}