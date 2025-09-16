import 'package:flutter/material.dart';

class CompactRating extends StatelessWidget {
  final double? rating;
  final int? count;
  final double iconSize;
  final TextStyle? textStyle;

  const CompactRating({
    super.key,
    required this.rating,
    this.count,
    this.iconSize = 16,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (rating == null || rating == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final style = textStyle ?? theme.textTheme.bodySmall;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: iconSize,
          color: Colors.amber,
        ),
        const SizedBox(width: 2),
        Text(
          rating!.toStringAsFixed(1),
          style: style?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: style?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}