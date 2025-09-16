import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/rating_display.dart';
import '../state/review_list_controller.dart';
import '../models/review.dart';
import 'write_review_dialog.dart';

class ReviewListPage extends ConsumerWidget {
  const ReviewListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewListControllerProvider());
    final myReviewAsync = ref.watch(myReviewControllerProvider);
    final summary = ref.watch(reviewSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bewertungen'),
        actions: [
          // Show write review button only if user hasn't reviewed yet
          if (myReviewAsync.valueOrNull == null)
            IconButton(
              icon: const Icon(Icons.rate_review),
              onPressed: () => _showWriteReviewDialog(context, ref),
            ),
        ],
      ),
      body: reviewsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Text('Fehler: $error'),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const EmptyState(
              icon: Icons.star_border,
              title: 'Noch keine Bewertungen',
              subtitle: 'Seien Sie der Erste, der diesen Salon bewertet!',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.read(reviewListControllerProvider().notifier).refresh(),
            child: CustomScrollView(
              slivers: [
                // Summary header
                if (summary != null)
                  SliverToBoxAdapter(
                    child: _ReviewSummaryHeader(summary: summary),
                  ),
                // My review (if exists)
                if (myReviewAsync.valueOrNull != null)
                  SliverToBoxAdapter(
                    child: _MyReviewCard(
                      review: myReviewAsync.value!,
                      onEdit: () => _showEditReviewDialog(context, ref, myReviewAsync.value!),
                      onDelete: () => _deleteReview(context, ref, myReviewAsync.value!.id),
                    ),
                  ),
                // Reviews list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final review = reviews[index];
                      // Skip my review in the list if it exists
                      if (myReviewAsync.valueOrNull?.id == review.id) {
                        return const SizedBox.shrink();
                      }
                      return _ReviewCard(review: review);
                    },
                    childCount: reviews.length,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showWriteReviewDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const WriteReviewDialog(),
    );

    if (result == true) {
      ref.invalidate(myReviewControllerProvider);
      ref.invalidate(reviewListControllerProvider());
    }
  }

  Future<void> _showEditReviewDialog(BuildContext context, WidgetRef ref, Review review) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => WriteReviewDialog(existingReview: review),
    );

    if (result == true) {
      ref.invalidate(myReviewControllerProvider);
      ref.invalidate(reviewListControllerProvider());
    }
  }

  Future<void> _deleteReview(BuildContext context, WidgetRef ref, int reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bewertung löschen'),
        content: const Text('Möchten Sie Ihre Bewertung wirklich löschen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Abbrechen'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(myReviewControllerProvider.notifier).deleteReview(reviewId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Bewertung wurde gelöscht')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Fehler: $e')),
          );
        }
      }
    }
  }
}

class _ReviewSummaryHeader extends StatelessWidget {
  final ReviewSummary summary;

  const _ReviewSummaryHeader({required this.summary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surface,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                summary.averageRating?.toStringAsFixed(1) ?? '0.0',
                style: theme.textTheme.displaySmall,
              ),
              const SizedBox(width: 8),
              RatingDisplay(
                rating: summary.averageRating ?? 0,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.totalReviews} Bewertungen',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // Rating distribution bars
          ...List.generate(5, (index) {
            final rating = 5 - index;
            final count = summary.ratingDistribution[rating] ?? 0;
            final percentage = summary.totalReviews > 0 
                ? (count / summary.totalReviews * 100) 
                : 0.0;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    child: Text('$rating', style: theme.textTheme.bodySmall),
                  ),
                  const Icon(Icons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: percentage / 100,
                      backgroundColor: theme.colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 40,
                    child: Text(
                      '$count',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;

  const _ReviewCard({required this.review});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.displayAuthorName,
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        dateFormat.format(review.createdAt),
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                RatingDisplay(rating: review.rating.toDouble()),
                if (review.isFromGoogle) ...[
                  const SizedBox(width: 8),
                  Image.asset(
                    'assets/images/google-logo.png',
                    height: 16,
                  ),
                ],
              ],
            ),
            if (review.body != null && review.body!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.body!),
            ],
          ],
        ),
      ),
    );
  }
}

class _MyReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MyReviewCard({
    required this.review,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy');

    return Card(
      margin: const EdgeInsets.all(16),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person),
                const SizedBox(width: 8),
                Text(
                  'Meine Bewertung',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Bearbeiten'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Löschen'),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                RatingDisplay(rating: review.rating.toDouble()),
                const Spacer(),
                Text(
                  dateFormat.format(review.createdAt),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
            if (review.body != null && review.body!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.body!),
            ],
          ],
        ),
      ),
    );
  }
}