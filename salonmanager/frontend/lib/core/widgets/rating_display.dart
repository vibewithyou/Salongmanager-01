import 'package:flutter/material.dart';

class RatingDisplay extends StatelessWidget {
  final double rating;
  final double size;
  final Color? color;
  final bool showNumber;

  const RatingDisplay({
    super.key,
    required this.rating,
    this.size = 20,
    this.color,
    this.showNumber = false,
  });

  @override
  Widget build(BuildContext context) {
    final starColor = color ?? Colors.amber;
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (index) {
          final starValue = index + 1;
          if (starValue <= rating) {
            return Icon(Icons.star, size: size, color: starColor);
          } else if (starValue - 0.5 <= rating) {
            return Icon(Icons.star_half, size: size, color: starColor);
          } else {
            return Icon(Icons.star_border, size: size, color: starColor);
          }
        }),
        if (showNumber) ...[
          const SizedBox(width: 4),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(fontSize: size * 0.8),
          ),
        ],
      ],
    );
  }
}