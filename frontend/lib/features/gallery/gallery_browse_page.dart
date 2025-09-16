import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/api_client.dart';
import '../../common/widgets/optimized_image.dart';
import 'gallery_album_page.dart';
import 'gallery_upload_page.dart';

class GalleryBrowsePage extends StatefulWidget {
  const GalleryBrowsePage({super.key});

  @override
  State<GalleryBrowsePage> createState() => _GalleryBrowsePageState();
}

class _GalleryBrowsePageState extends State<GalleryBrowsePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Galerie'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Alle'),
            Tab(text: 'Vorher/Nachher'),
            Tab(text: 'Deine Uploads'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const GalleryUploadPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _AllPhotosTab(),
          _BeforeAfterTab(),
          _MyUploadsTab(),
        ],
      ),
    );
  }
}

class _AllPhotosTab extends StatefulWidget {
  @override
  State<_AllPhotosTab> createState() => _AllPhotosTabState();
}

class _AllPhotosTabState extends State<_AllPhotosTab> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _albums = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      final response = await _apiClient.get('/gallery/albums');
      setState(() {
        _albums = response.data;
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_albums.isEmpty) {
      return const Center(
        child: Text('Keine Alben gefunden'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _albums.length,
      itemBuilder: (context, index) {
        final album = _albums[index];
        final photos = album['photos'] as List<dynamic>? ?? [];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GalleryAlbumPage(albumId: album['id']),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (photos.isNotEmpty)
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: photos.length,
                      itemBuilder: (context, photoIndex) {
                        final photo = photos[photoIndex];
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.all(4),
                          child: OptimizedImage(
                            imageUrl: photo['path'],
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album['title'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${photos.length} Fotos',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BeforeAfterTab extends StatefulWidget {
  @override
  State<_BeforeAfterTab> createState() => _BeforeAfterTabState();
}

class _BeforeAfterTabState extends State<_BeforeAfterTab> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _beforeAfterGroups = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadBeforeAfterPhotos();
  }

  Future<void> _loadBeforeAfterPhotos() async {
    try {
      final response = await _apiClient.get('/gallery/photos?approved=1');
      final photos = response.data['data'] as List<dynamic>? ?? [];
      
      // Group photos by before_after_group
      final Map<String, List<dynamic>> groups = {};
      for (final photo in photos) {
        final groupId = photo['before_after_group'];
        if (groupId != null) {
          groups.putIfAbsent(groupId, () => []).add(photo);
        }
      }
      
      setState(() {
        _beforeAfterGroups = groups.values.where((group) => group.length >= 2).toList();
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_beforeAfterGroups.isEmpty) {
      return const Center(
        child: Text('Keine Vorher/Nachher Fotos gefunden'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _beforeAfterGroups.length,
      itemBuilder: (context, index) {
        final group = _beforeAfterGroups[index];
        final beforePhoto = group.first;
        final afterPhoto = group.length > 1 ? group[1] : group.first;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Vorher / Nachher',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Vorher'),
                        const SizedBox(height: 8),
                        AspectRatio(
                          aspectRatio: 1,
                          child: OptimizedImage(
                            imageUrl: beforePhoto['path'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      children: [
                        const Text('Nachher'),
                        const SizedBox(height: 8),
                        AspectRatio(
                          aspectRatio: 1,
                          child: OptimizedImage(
                            imageUrl: afterPhoto['path'],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MyUploadsTab extends StatefulWidget {
  @override
  State<_MyUploadsTab> createState() => _MyUploadsTabState();
}

class _MyUploadsTabState extends State<_MyUploadsTab> {
  final ApiClient _apiClient = ApiClient();
  List<dynamic> _photos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadMyPhotos();
  }

  Future<void> _loadMyPhotos() async {
    try {
      final response = await _apiClient.get('/gallery/photos');
      setState(() {
        _photos = response.data['data'] as List<dynamic>? ?? [];
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
      return const Center(child: CircularProgressIndicator());
    }

    if (_photos.isEmpty) {
      return const Center(
        child: Text('Keine eigenen Uploads gefunden'),
      );
    }

    return GridView.builder(
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
              // TODO: Show photo details
            },
            child: OptimizedImage(
              imageUrl: photo['path'],
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }
}
