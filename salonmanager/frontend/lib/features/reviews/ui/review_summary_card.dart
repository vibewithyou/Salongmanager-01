import 'package:flutter/material.dart';
import '../../../core/widgets/rating_display.dart';
import 'review_list_page.dart';

class ReviewSummaryCard extends StatelessWidget {
  final double? averageRating;
  final int reviewCount;
  final VoidCallback? onTap;

  const ReviewSummaryCard({
    super.key,
    required this.averageRating,
    required this.reviewCount,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap ?? () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const ReviewListPage(),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.star,
              color: Colors.amber,
              size: 32,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        averageRating?.toStringAsFixed(1) ?? '0.0',
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(width: 8),
                      RatingDisplay(
                        rating: averageRating ?? 0,
                        size: 16,
                      ),
                    ],
                  ),
                  Text(
                    reviewCount == 0
                        ? 'Noch keine Bewertungen'
                        : reviewCount == 1
                            ? '1 Bewertung'
                            : '$reviewCount Bewertungen',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}