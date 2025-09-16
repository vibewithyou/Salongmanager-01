import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

@freezed
class Review with _$Review {
  const factory Review({
    required int id,
    required int salonId,
    int? userId,
    required int rating,
    String? body,
    List<int>? mediaIds,
    required String source,
    String? sourceId,
    required String authorName,
    required bool approved,
    required DateTime createdAt,
    required DateTime updatedAt,
    
    // Relations
    Map<String, dynamic>? user,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

@freezed
class ReviewSummary with _$ReviewSummary {
  const factory ReviewSummary({
    required double? averageRating,
    required int totalReviews,
    required Map<int, int> ratingDistribution,
  }) = _ReviewSummary;

  factory ReviewSummary.fromJson(Map<String, dynamic> json) => _$ReviewSummaryFromJson(json);
}

// Extension for display helpers
extension ReviewX on Review {
  String get displayAuthorName {
    if (user != null && user!['name'] != null) {
      return user!['name'] as String;
    }
    return authorName;
  }
  
  bool get isFromGoogle => source == 'google';
  bool get isLocal => source == 'local';
  bool get canEdit => isLocal && userId != null;
}