import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gallery_photo.dart';
import '../state/gallery_controller.dart';
import 'gallery_photo_tile.dart';

class CustomerGalleryPage extends ConsumerStatefulWidget {
  final int customerId;
  final String customerName;

  const CustomerGalleryPage({
    Key? key,
    required this.customerId,
    required this.customerName,
  }) : super(key: key);

  @override
  ConsumerState<CustomerGalleryPage> createState() => _CustomerGalleryPageState();
}

class _CustomerGalleryPageState extends ConsumerState<CustomerGalleryPage> {
  bool _showApprovedOnly = true;
  String? _beforeAfterGroup;

  @override
  Widget build(BuildContext context) {
    final galleryParams = {
      'customerId': widget.customerId,
      'approved': _showApprovedOnly,
      'beforeAfterGroup': _beforeAfterGroup,
    };

    final galleryAsync = ref.watch(customerGalleryProvider(galleryParams));

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.customerName}\'s Gallery'),
        actions: [
          // Filter toggle
          IconButton(
            icon: Icon(_showApprovedOnly ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                _showApprovedOnly = !_showApprovedOnly;
              });
            },
            tooltip: _showApprovedOnly ? 'Show all photos' : 'Show approved only',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                FilterChip(
                  label: const Text('Before/After'),
                  selected: _beforeAfterGroup != null,
                  onSelected: (selected) {
                    setState(() {
                      _beforeAfterGroup = selected ? 'group-1' : null;
                    });
                  },
                ),
                FilterChip(
                  label: Text(_showApprovedOnly ? 'Approved' : 'All'),
                  selected: true,
                  onSelected: (selected) {
                    setState(() {
                      _showApprovedOnly = !_showApprovedOnly;
                    });
                  },
                ),
              ],
            ),
          ),
          // Gallery grid
          Expanded(
            child: galleryAsync.when(
              data: (photos) {
                if (photos.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No photos found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: photos.length,
                  itemBuilder: (context, index) {
                    final photo = photos[index];
                    return GalleryPhotoTile(
                      photo: photo,
                      onTap: () => _showPhotoDetail(context, photo),
                      onBookFromPhoto: () => _bookFromPhoto(context, photo),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stackTrace) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading gallery: $error',
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        ref.invalidate(customerGalleryProvider(galleryParams));
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPhotoDetail(BuildContext context, GalleryPhoto photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: Text(photo.albumTitle ?? 'Photo'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            Expanded(
              child: Image.network(
                photo.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.image_not_supported, size: 64),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _bookFromPhoto(context, photo),
                    icon: const Icon(Icons.calendar_today),
                    label: const Text('Book from this photo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _bookFromPhoto(BuildContext context, GalleryPhoto photo) {
    // Navigate to booking wizard with photo context
    Navigator.of(context).pushNamed(
      '/booking-wizard',
      arguments: {
        'source': 'photo',
        'photoId': photo.id,
        'photoUrl': photo.imageUrl,
      },
    );
  }
}
