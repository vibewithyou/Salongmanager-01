import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Optimized image widget with caching and size optimization
class OptimizedImage extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool useThumbnail;
  final int? cacheWidth;
  final int? cacheHeight;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
    this.useThumbnail = true,
    this.cacheWidth,
    this.cacheHeight,
  });

  /// Create a thumbnail image (150x150)
  factory OptimizedImage.thumbnail({
    required String imageUrl,
    String? thumbnailUrl,
    double size = 150,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      width: size,
      height: size,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      useThumbnail: true,
      cacheWidth: size.toInt(),
      cacheHeight: size.toInt(),
    );
  }

  /// Create a medium image (400x400)
  factory OptimizedImage.medium({
    required String imageUrl,
    String? thumbnailUrl,
    double maxSize = 400,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      width: maxSize,
      height: maxSize,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      useThumbnail: true,
      cacheWidth: maxSize.toInt(),
      cacheHeight: maxSize.toInt(),
    );
  }

  /// Create a web-optimized image (max 800px)
  factory OptimizedImage.web({
    required String imageUrl,
    String? thumbnailUrl,
    double? maxWidth,
    double? maxHeight,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    Widget? placeholder,
    Widget? errorWidget,
  }) {
    return OptimizedImage(
      imageUrl: imageUrl,
      thumbnailUrl: thumbnailUrl,
      width: maxWidth,
      height: maxHeight,
      fit: fit,
      borderRadius: borderRadius,
      placeholder: placeholder,
      errorWidget: errorWidget,
      useThumbnail: true,
      cacheWidth: maxWidth?.toInt(),
      cacheHeight: maxHeight?.toInt(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveImageUrl = useThumbnail && thumbnailUrl != null 
        ? thumbnailUrl! 
        : imageUrl;

    Widget imageWidget = CachedNetworkImage(
      imageUrl: effectiveImageUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
      placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) => errorWidget ?? _buildDefaultError(),
      fadeInDuration: const Duration(milliseconds: 200),
      fadeOutDuration: const Duration(milliseconds: 100),
    );

    if (borderRadius != null) {
      imageWidget = ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return RepaintBoundary(
      child: imageWidget,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Icon(
        Icons.broken_image,
        color: Colors.grey,
        size: 32,
      ),
    );
  }
}

/// Gallery image widget for photo galleries
class GalleryImage extends StatelessWidget {
  final String imageUrl;
  final String? thumbnailUrl;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const GalleryImage({
    super.key,
    required this.imageUrl,
    this.thumbnailUrl,
    this.onTap,
    this.width,
    this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: OptimizedImage.medium(
        imageUrl: imageUrl,
        thumbnailUrl: thumbnailUrl,
        width: width,
        height: height,
        borderRadius: borderRadius,
        placeholder: _buildGalleryPlaceholder(),
        errorWidget: _buildGalleryError(),
      ),
    );
  }

  Widget _buildGalleryPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.image,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildGalleryError() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: borderRadius,
      ),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: Colors.grey,
          size: 24,
        ),
      ),
    );
  }
}

/// Avatar image widget for user profiles
class AvatarImage extends StatelessWidget {
  final String? imageUrl;
  final String? thumbnailUrl;
  final double size;
  final String? fallbackText;
  final Color? backgroundColor;
  final Color? textColor;

  const AvatarImage({
    super.key,
    this.imageUrl,
    this.thumbnailUrl,
    this.size = 40,
    this.fallbackText,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackAvatar(theme, cs);
    }

    return OptimizedImage.thumbnail(
      imageUrl: imageUrl!,
      thumbnailUrl: thumbnailUrl,
      size: size,
      fit: BoxFit.cover,
      borderRadius: BorderRadius.circular(size / 2),
      placeholder: _buildFallbackAvatar(theme, cs),
      errorWidget: _buildFallbackAvatar(theme, cs),
    );
  }

  Widget _buildFallbackAvatar(ThemeData theme, ColorScheme cs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.primaryContainer,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Center(
        child: Text(
          fallbackText ?? '?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: textColor ?? cs.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
