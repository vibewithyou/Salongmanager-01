import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/widgets/rating_display.dart';
import '../state/review_list_controller.dart';
import '../models/review.dart';

class ReviewModerationPage extends ConsumerStatefulWidget {
  const ReviewModerationPage({super.key});

  @override
  ConsumerState<ReviewModerationPage> createState() => _ReviewModerationPageState();
}

class _ReviewModerationPageState extends ConsumerState<ReviewModerationPage> {
  bool? _approvedFilter;

  @override
  Widget build(BuildContext context) {
    final reviewsAsync = ref.watch(
      reviewModerationControllerProvider(approved: _approvedFilter),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bewertungen moderieren'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Alle'),
                  selected: _approvedFilter == null,
                  onSelected: (selected) {
                    setState(() => _approvedFilter = null);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Freigegeben'),
                  selected: _approvedFilter == true,
                  onSelected: (selected) {
                    setState(() => _approvedFilter = true);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Verborgen'),
                  selected: _approvedFilter == false,
                  onSelected: (selected) {
                    setState(() => _approvedFilter = false);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: reviewsAsync.when(
        loading: () => const LoadingIndicator(),
        error: (error, stack) => Center(
          child: Text('Fehler: $error'),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return const EmptyState(
              icon: Icons.rate_review,
              title: 'Keine Bewertungen',
              subtitle: 'Es gibt keine Bewertungen zum Moderieren',
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(
              reviewModerationControllerProvider(approved: _approvedFilter).future,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _ModerationReviewCard(
                  review: review,
                  onToggleApproval: () => _toggleApproval(review.id),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _toggleApproval(int reviewId) async {
    try {
      await ref.read(
        reviewModerationControllerProvider(approved: _approvedFilter).notifier,
      ).toggleApproval(reviewId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Freigabestatus wurde geändert')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler: $e')),
        );
      }
    }
  }
}

class _ModerationReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onToggleApproval;

  const _ModerationReviewCard({
    required this.review,
    required this.onToggleApproval,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Chip(
                  label: Text(review.approved ? 'Freigegeben' : 'Verborgen'),
                  backgroundColor: review.approved 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.orange.withOpacity(0.2),
                  labelStyle: TextStyle(
                    color: review.approved ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                if (review.isFromGoogle)
                  Chip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/google-logo.png',
                          height: 12,
                        ),
                        const SizedBox(width: 4),
                        const Text('Google'),
                      ],
                    ),
                  ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    review.approved ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: review.isFromGoogle ? null : onToggleApproval,
                  tooltip: review.approved ? 'Verbergen' : 'Freigeben',
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Review info
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
              ],
            ),
            if (review.body != null && review.body!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(review.body!),
            ],
            // User info if available
            if (review.user != null) ...[
              const Divider(height: 24),
              Row(
                children: [
                  const Icon(Icons.person, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Kunde: ${review.user!['email'] ?? 'Unbekannt'}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}