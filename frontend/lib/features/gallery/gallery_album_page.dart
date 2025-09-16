import 'package:flutter/material.dart';
import '../../core/api_client.dart';
import '../../common/widgets/optimized_image.dart';

class GalleryAlbumPage extends StatefulWidget {
  final int albumId;

  const GalleryAlbumPage({super.key, required this.albumId});

  @override
  State<GalleryAlbumPage> createState() => _GalleryAlbumPageState();
}

class _GalleryAlbumPageState extends State<GalleryAlbumPage> {
  final ApiClient _apiClient = ApiClient();
  Map<String, dynamic>? _album;
  List<dynamic> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbum();
  }

  Future<void> _loadAlbum() async {
    try {
      final response = await _apiClient.get('/gallery/albums/${widget.albumId}');
      setState(() {
        _album = response.data;
        _photos = _album?['photos'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_album == null) {
      return const Scaffold(
        body: Center(child: Text('Album nicht gefunden')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_album!['title']),
      ),
      body: _photos.isEmpty
          ? const Center(child: Text('Keine Fotos in diesem Album'))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length,
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      _showPhotoDialog(photo);
                    },
                    child: OptimizedImage(
                      imageUrl: photo['path'],
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showPhotoDialog(Map<String, dynamic> photo) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text('Foto'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Expanded(
              child: OptimizedImage(
                imageUrl: photo['path'],
                fit: BoxFit.contain,
              ),
            ),
            if (photo['before_after_group'] != null)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Teil einer Vorher/Nachher Serie',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
