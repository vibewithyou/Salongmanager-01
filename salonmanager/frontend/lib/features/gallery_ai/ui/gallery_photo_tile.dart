import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gallery_photo.dart';
import '../state/gallery_controller.dart';

class GalleryPhotoTile extends ConsumerWidget {
  final GalleryPhoto photo;
  final VoidCallback? onTap;
  final VoidCallback? onBookFromPhoto;

  const GalleryPhotoTile({
    Key? key,
    required this.photo,
    this.onTap,
    this.onBookFromPhoto,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoStats = ref.watch(photoInteractionProvider(photo.id));

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    photo.thumbnailUrl ?? photo.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(
                          Icons.image_not_supported,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  // Overlay with interaction buttons
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Like button
                        _buildInteractionButton(
                          context,
                          ref,
                          icon: photoStats.when(
                            data: (stats) => stats.isLiked ? Icons.favorite : Icons.favorite_border,
                            loading: () => Icons.favorite_border,
                            error: (_, __) => Icons.favorite_border,
                          ),
                          color: photoStats.when(
                            data: (stats) => stats.isLiked ? Colors.red : Colors.white,
                            loading: () => Colors.white,
                            error: (_, __) => Colors.white,
                          ),
                          onTap: () {
                            ref.read(photoInteractionProvider(photo.id).notifier).toggleLike();
                          },
                        ),
                        const SizedBox(width: 4),
                        // Favorite button
                        _buildInteractionButton(
                          context,
                          ref,
                          icon: photoStats.when(
                            data: (stats) => stats.isFavorited ? Icons.star : Icons.star_border,
                            loading: () => Icons.star_border,
                            error: (_, __) => Icons.star_border,
                          ),
                          color: photoStats.when(
                            data: (stats) => stats.isFavorited ? Colors.amber : Colors.white,
                            loading: () => Colors.white,
                            error: (_, __) => Colors.white,
                          ),
                          onTap: () {
                            ref.read(photoInteractionProvider(photo.id).notifier).toggleFavorite();
                          },
                        ),
                      ],
                    ),
                  ),
                  // Book from photo button
                  if (onBookFromPhoto != null)
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: _buildInteractionButton(
                        context,
                        ref,
                        icon: Icons.calendar_today,
                        color: Colors.blue,
                        onTap: onBookFromPhoto,
                      ),
                    ),
                ],
              ),
            ),
            // Photo info
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats
                  photoStats.when(
                    data: (stats) => Row(
                      children: [
                        if (stats.likes > 0) ...[
                          const Icon(Icons.favorite, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Text('${stats.likes}'),
                          const SizedBox(width: 16),
                        ],
                        if (stats.isFavorited) ...[
                          const Icon(Icons.star, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          const Text('Saved'),
                        ],
                      ],
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                  // Album info
                  if (photo.albumTitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      photo.albumTitle!,
                      style: Theme.of(context).textTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onTap,
        padding: const EdgeInsets.all(8),
        constraints: const BoxConstraints(
          minWidth: 40,
          minHeight: 40,
        ),
      ),
    );
  }
}
