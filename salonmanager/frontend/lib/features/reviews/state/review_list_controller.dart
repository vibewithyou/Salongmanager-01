import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/review_repository.dart';
import '../models/review.dart';

part 'review_list_controller.g.dart';

@riverpod
class ReviewListController extends _$ReviewListController {
  @override
  Future<List<Review>> build({
    String? source,
    int? rating,
  }) async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.getReviews(
      source: source,
      rating: rating,
    );

    if (response.success && response.data != null) {
      // Store summary in a separate provider if needed
      if (response.meta?['summary'] != null) {
        ref.read(reviewSummaryProvider.notifier).state = response.meta!['summary'] as ReviewSummary;
      }
      return response.data!;
    }

    throw Exception(response.message ?? 'Fehler beim Laden der Bewertungen');
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }

  Future<void> loadMore() async {
    // TODO: Implement pagination
  }
}

// Provider for review summary
final reviewSummaryProvider = StateProvider<ReviewSummary?>((ref) => null);

// Provider for my review
@riverpod
class MyReviewController extends _$MyReviewController {
  @override
  Future<Review?> build() async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.getMyReview();

    if (response.success) {
      return response.data;
    }

    return null;
  }

  Future<void> createReview({
    required int rating,
    String? body,
    List<int>? mediaIds,
  }) async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.createReview(
      rating: rating,
      body: body,
      mediaIds: mediaIds,
    );

    if (response.success && response.data != null) {
      state = AsyncValue.data(response.data);
      // Refresh the review list
      ref.invalidate(reviewListControllerProvider);
      return;
    }

    throw Exception(response.message ?? 'Fehler beim Erstellen der Bewertung');
  }

  Future<void> updateReview({
    required int reviewId,
    int? rating,
    String? body,
    List<int>? mediaIds,
  }) async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.updateReview(
      reviewId: reviewId,
      rating: rating,
      body: body,
      mediaIds: mediaIds,
    );

    if (response.success && response.data != null) {
      state = AsyncValue.data(response.data);
      // Refresh the review list
      ref.invalidate(reviewListControllerProvider);
      return;
    }

    throw Exception(response.message ?? 'Fehler beim Aktualisieren der Bewertung');
  }

  Future<void> deleteReview(int reviewId) async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.deleteReview(reviewId);

    if (response.success) {
      state = const AsyncValue.data(null);
      // Refresh the review list
      ref.invalidate(reviewListControllerProvider);
      return;
    }

    throw Exception(response.message ?? 'Fehler beim Löschen der Bewertung');
  }
}

// Provider for moderation reviews (salon owners/managers)
@riverpod
class ReviewModerationController extends _$ReviewModerationController {
  @override
  Future<List<Review>> build({bool? approved}) async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.getModerationReviews(approved: approved);

    if (response.success && response.data != null) {
      return response.data!;
    }

    throw Exception(response.message ?? 'Fehler beim Laden der Moderationsbewertungen');
  }

  Future<void> toggleApproval(int reviewId) async {
    final repository = ref.read(reviewRepositoryProvider);
    final response = await repository.toggleApproval(reviewId);

    if (response.success) {
      ref.invalidateSelf();
      // Also refresh the public review list
      ref.invalidate(reviewListControllerProvider);
      return;
    }

    throw Exception(response.message ?? 'Fehler beim Ändern des Freigabestatus');
  }
}