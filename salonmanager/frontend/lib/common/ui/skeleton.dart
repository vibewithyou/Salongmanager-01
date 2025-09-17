import 'package:flutter/material.dart';
import '../../core/theme/tokens.dart';

/// Simple skeleton loader without shimmer effect
class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  
  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      width: width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.5),
        borderRadius: borderRadius ?? SMTokens.rSm,
      ),
    );
  }
}

/// Text skeleton for loading text content
class TextSkeleton extends StatelessWidget {
  final double? width;
  final double height;
  final int lines;
  final double lineSpacing;
  final EdgeInsetsGeometry? margin;
  
  const TextSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.lines = 1,
    this.lineSpacing = SMTokens.s2,
    this.margin,
  });
  
  @override
  Widget build(BuildContext context) {
    if (lines == 1) {
      return Skeleton(
        width: width,
        height: height,
        margin: margin,
      );
    }
    
    return Container(
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < lines; i++) ...[
            Skeleton(
              width: i == lines - 1 ? (width ?? double.infinity) * 0.6 : width,
              height: height,
            ),
            if (i < lines - 1) SizedBox(height: lineSpacing),
          ],
        ],
      ),
    );
  }
}

/// List tile skeleton
class ListTileSkeleton extends StatelessWidget {
  final bool hasLeading;
  final bool hasTrailing;
  final int subtitleLines;
  final EdgeInsetsGeometry? padding;
  
  const ListTileSkeleton({
    super.key,
    this.hasLeading = true,
    this.hasTrailing = false,
    this.subtitleLines = 1,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(SMTokens.s4),
      child: Row(
        children: [
          if (hasLeading) ...[
            const Skeleton(
              width: 48,
              height: 48,
              borderRadius: SMTokens.rFull,
            ),
            const SizedBox(width: SMTokens.s3),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Skeleton(height: 20),
                if (subtitleLines > 0) ...[
                  const SizedBox(height: SMTokens.s2),
                  TextSkeleton(
                    height: 14,
                    lines: subtitleLines,
                  ),
                ],
              ],
            ),
          ),
          if (hasTrailing) ...[
            const SizedBox(width: SMTokens.s3),
            const Skeleton(
              width: 24,
              height: 24,
            ),
          ],
        ],
      ),
    );
  }
}

/// Card skeleton
class CardSkeleton extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Widget? child;
  
  const CardSkeleton({
    super.key,
    this.height,
    this.margin,
    this.padding,
    this.child,
  });
  
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    
    return Container(
      height: height,
      margin: margin ?? const EdgeInsets.all(SMTokens.s2),
      padding: padding ?? const EdgeInsets.all(SMTokens.s4),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: SMTokens.rLg,
        border: Border.all(
          color: cs.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: child,
    );
  }
}

/// Grid skeleton
class GridSkeleton extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double aspectRatio;
  final double spacing;
  final EdgeInsetsGeometry? padding;
  
  const GridSkeleton({
    super.key,
    this.itemCount = 6,
    this.crossAxisCount = 2,
    this.aspectRatio = 1,
    this.spacing = SMTokens.s3,
    this.padding,
  });
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: padding,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: aspectRatio,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const Skeleton(),
    );
  }
}

/// Feature card skeleton
class FeatureCardSkeleton extends StatelessWidget {
  final bool compact;
  
  const FeatureCardSkeleton({
    super.key,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    return CardSkeleton(
      padding: EdgeInsets.all(compact ? SMTokens.s3 : SMTokens.s4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: compact ? CrossAxisAlignment.center : CrossAxisAlignment.start,
        children: [
          Skeleton(
            width: compact ? 48 : 56,
            height: compact ? 48 : 56,
            borderRadius: SMTokens.rMd,
          ),
          SizedBox(height: compact ? SMTokens.s2 : SMTokens.s3),
          Skeleton(
            width: compact ? 80 : 120,
            height: compact ? 16 : 20,
          ),
          if (!compact) ...[
            const SizedBox(height: SMTokens.s2),
            const TextSkeleton(
              height: 14,
              lines: 2,
            ),
          ],
        ],
      ),
    );
  }
}