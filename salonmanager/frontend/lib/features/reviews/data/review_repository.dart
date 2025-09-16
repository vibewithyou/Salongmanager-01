import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_response.dart';
import '../models/review.dart';

part 'review_repository.g.dart';

class ReviewRepository {
  final Dio _dio = ApiClient.build();

  /// Get all reviews for the current salon (public endpoint)
  Future<ApiResponse<List<Review>>> getReviews({
    int page = 1,
    int perPage = 20,
    String? source,
    int? rating,
  }) async {
    try {
      final response = await _dio.get(
        '/reviews',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (source != null) 'source': source,
          if (rating != null) 'rating': rating,
        },
      );

      final items = response.data['items']['data'] as List;
      final reviews = items.map((json) => Review.fromJson(Map<String, dynamic>.from(json))).toList();
      
      final summary = response.data['summary'] != null
          ? ReviewSummary.fromJson(Map<String, dynamic>.from(response.data['summary']))
          : null;

      return ApiResponse.success(
        data: reviews,
        meta: {
          'pagination': response.data['items'],
          'summary': summary,
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Laden der Bewertungen',
      );
    }
  }

  /// Get my review for the current salon
  Future<ApiResponse<Review?>> getMyReview() async {
    try {
      final response = await _dio.get('/reviews/my-review');
      
      if (response.data['review'] != null) {
        final review = Review.fromJson(Map<String, dynamic>.from(response.data['review']));
        return ApiResponse.success(data: review);
      }
      
      return ApiResponse.success(data: null);
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Laden Ihrer Bewertung',
      );
    }
  }

  /// Create a new review
  Future<ApiResponse<Review>> createReview({
    required int rating,
    String? body,
    List<int>? mediaIds,
  }) async {
    try {
      final response = await _dio.post(
        '/reviews',
        data: {
          'rating': rating,
          'body': body,
          'media_ids': mediaIds ?? [],
        },
      );

      final review = Review.fromJson(Map<String, dynamic>.from(response.data['review']));
      return ApiResponse.success(
        data: review,
        message: response.data['message'] ?? 'Bewertung wurde erstellt',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Erstellen der Bewertung',
      );
    }
  }

  /// Update an existing review
  Future<ApiResponse<Review>> updateReview({
    required int reviewId,
    int? rating,
    String? body,
    List<int>? mediaIds,
  }) async {
    try {
      final response = await _dio.put(
        '/reviews/$reviewId',
        data: {
          if (rating != null) 'rating': rating,
          if (body != null) 'body': body,
          if (mediaIds != null) 'media_ids': mediaIds,
        },
      );

      final review = Review.fromJson(Map<String, dynamic>.from(response.data['review']));
      return ApiResponse.success(
        data: review,
        message: response.data['message'] ?? 'Bewertung wurde aktualisiert',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Aktualisieren der Bewertung',
      );
    }
  }

  /// Delete a review
  Future<ApiResponse<void>> deleteReview(int reviewId) async {
    try {
      final response = await _dio.delete('/reviews/$reviewId');
      return ApiResponse.success(
        data: null,
        message: response.data['message'] ?? 'Bewertung wurde gelöscht',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Löschen der Bewertung',
      );
    }
  }

  /// Get reviews for moderation (salon owners/managers only)
  Future<ApiResponse<List<Review>>> getModerationReviews({
    int page = 1,
    int perPage = 20,
    bool? approved,
  }) async {
    try {
      final response = await _dio.get(
        '/reviews/moderation',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (approved != null) 'approved': approved,
        },
      );

      final items = response.data['items']['data'] as List;
      final reviews = items.map((json) => Review.fromJson(Map<String, dynamic>.from(json))).toList();

      return ApiResponse.success(
        data: reviews,
        meta: {
          'pagination': response.data['items'],
        },
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Laden der Moderationsbewertungen',
      );
    }
  }

  /// Toggle approval status of a review
  Future<ApiResponse<Review>> toggleApproval(int reviewId) async {
    try {
      final response = await _dio.post('/reviews/$reviewId/toggle-approval');

      final review = Review.fromJson(Map<String, dynamic>.from(response.data['review']));
      return ApiResponse.success(
        data: review,
        message: response.data['message'] ?? 'Freigabestatus wurde geändert',
      );
    } on DioException catch (e) {
      return ApiResponse.error(
        message: e.response?.data['message'] ?? 'Fehler beim Ändern des Freigabestatus',
      );
    }
  }
}

@riverpod
ReviewRepository reviewRepository(ReviewRepositoryRef ref) {
  return ReviewRepository();
}