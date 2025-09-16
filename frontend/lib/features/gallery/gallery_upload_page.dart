import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/api_client.dart';

class GalleryUploadPage extends StatefulWidget {
  const GalleryUploadPage({super.key});

  @override
  State<GalleryUploadPage> createState() => _GalleryUploadPageState();
}

class _GalleryUploadPageState extends State<GalleryUploadPage> {
  final ApiClient _apiClient = ApiClient();
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  bool _consentGiven = false;
  bool _isBeforeAfter = false;
  bool _uploading = false;
  int? _selectedAlbumId;
  List<Map<String, dynamic>> _albums = [];

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  Future<void> _loadAlbums() async {
    try {
      final response = await _apiClient.get('/gallery/albums');
      setState(() {
        _albums = (response.data as List<dynamic>)
            .map((album) => album as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden der Alben: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 2048,
        maxHeight: 2048,
        imageQuality: 85,
      );
      setState(() {
        _selectedImage = image;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Auswählen des Bildes: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || !_consentGiven) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte wählen Sie ein Bild aus und geben Sie Ihre Einwilligung')),
      );
      return;
    }

    setState(() {
      _uploading = true;
    });

    try {
      final formData = FormData();
      formData.files.add(MapEntry(
        'image',
        await MultipartFile.fromFile(_selectedImage!.path),
      ));
      formData.fields.add(MapEntry('consent_given', 'true'));
      formData.fields.add(MapEntry('album_id', _selectedAlbumId?.toString() ?? ''));
      if (_isBeforeAfter) {
        formData.fields.add(MapEntry('before_after_group', ''));
      }

      await _apiClient.post('/gallery/photos', data: formData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bild erfolgreich hochgeladen')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Hochladen: $e')),
        );
      }
    } finally {
      setState(() {
        _uploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bild hochladen'),
        actions: [
          if (_selectedImage != null && _consentGiven)
            TextButton(
              onPressed: _uploading ? null : _uploadImage,
              child: _uploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Hochladen'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image selection
            Card(
              child: InkWell(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage == null
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate, size: 48),
                              SizedBox(height: 8),
                              Text('Bild auswählen'),
                            ],
                          ),
                        )
                      : Image.network(
                          _selectedImage!.path,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Album selection
            if (_albums.isNotEmpty) ...[
              const Text('Album auswählen:', style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedAlbumId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Album auswählen (optional)',
                ),
                items: [
                  const DropdownMenuItem<int>(
                    value: null,
                    child: Text('Kein Album'),
                  ),
                  ..._albums.map((album) => DropdownMenuItem<int>(
                        value: album['id'],
                        child: Text(album['title']),
                      )),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedAlbumId = value;
                  });
                },
              ),
              const SizedBox(height: 16),
            ],

            // Before/After option
            CheckboxListTile(
              title: const Text('Vorher/Nachher Foto'),
              subtitle: const Text('Dieses Foto ist Teil einer Vorher/Nachher Serie'),
              value: _isBeforeAfter,
              onChanged: (value) {
                setState(() {
                  _isBeforeAfter = value ?? false;
                });
              },
            ),

            // Consent checkbox
            CheckboxListTile(
              title: const Text('Einwilligung zur Veröffentlichung'),
              subtitle: const Text(
                'Ich stimme zu, dass dieses Foto in der Galerie veröffentlicht werden darf. '
                'Meine Einwilligung kann jederzeit widerrufen werden.',
              ),
              value: _consentGiven,
              onChanged: (value) {
                setState(() {
                  _consentGiven = value ?? false;
                });
              },
            ),

            const SizedBox(height: 16),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedImage != null && _consentGiven && !_uploading
                    ? _uploadImage
                    : null,
                child: _uploading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 8),
                          Text('Wird hochgeladen...'),
                        ],
                      )
                    : const Text('Bild hochladen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
