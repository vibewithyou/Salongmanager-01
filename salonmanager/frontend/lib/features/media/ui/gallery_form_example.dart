import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'media_uploader.dart';

class GalleryFormExample extends ConsumerStatefulWidget {
  const GalleryFormExample({super.key});

  @override
  ConsumerState<GalleryFormExample> createState() => _GalleryFormExampleState();
}

class _GalleryFormExampleState extends ConsumerState<GalleryFormExample> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  List<Map<String, dynamic>> _uploadedFiles = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gallery Photo Upload'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Photo Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              const Text(
                'Upload Photos',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              MediaUploader(
                ownerType: 'GalleryPhoto',
                ownerId: 1, // This would be the actual gallery photo ID
                consentRequiredDefault: false,
                onUploadComplete: (fileData) {
                  setState(() {
                    _uploadedFiles.add(fileData);
                  });
                },
              ),
              const SizedBox(height: 24),
              if (_uploadedFiles.isNotEmpty) ...[
                const Text(
                  'Uploaded Files:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ..._uploadedFiles.map((file) => Card(
                  child: ListTile(
                    leading: const Icon(Icons.image),
                    title: Text('File ID: ${file['id']}'),
                    subtitle: Text('Size: ${file['bytes']} bytes'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        setState(() {
                          _uploadedFiles.remove(file);
                        });
                      },
                    ),
                  ),
                )),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Save Gallery Photo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically:
      // 1. Create the gallery photo record
      // 2. Associate the uploaded media files with it
      // 3. Navigate back or show success message
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gallery photo saved with ${_uploadedFiles.length} files'),
        ),
      );
    }
  }
}