import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/media_repository.dart';

class MediaUploader extends ConsumerStatefulWidget {
  final String ownerType; // e.g. 'GalleryPhoto'
  final int ownerId; // e.g. photo-id (oder später erst nach finalize verknüpfen)
  final bool consentRequiredDefault;
  final Function(Map<String, dynamic>)? onUploadComplete;

  const MediaUploader({
    super.key,
    required this.ownerType,
    required this.ownerId,
    this.consentRequiredDefault = false,
    this.onUploadComplete,
  });

  @override
  ConsumerState<MediaUploader> createState() => _MediaUploaderState();
}

class _MediaUploaderState extends ConsumerState<MediaUploader> {
  double progress = 0;
  bool consentRequired = false;
  final subjectName = TextEditingController();
  final subjectContact = TextEditingController();
  bool isUploading = false;

  @override
  void initState() {
    consentRequired = widget.consentRequiredDefault;
    super.initState();
  }

  @override
  void dispose() {
    subjectName.dispose();
    subjectContact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          title: const Text('Einwilligung erforderlich (personenbezogenes Foto)'),
          value: consentRequired,
          onChanged: (value) => setState(() => consentRequired = value ?? false),
        ),
        if (consentRequired) ...[
          TextField(
            controller: subjectName,
            decoration: const InputDecoration(
              labelText: 'Name der abgebildeten Person',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: subjectContact,
            decoration: const InputDecoration(
              labelText: 'Kontakt (E-Mail/Telefon)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
        ],
        ElevatedButton.icon(
          onPressed: isUploading ? null : _pickAndUpload,
          icon: isUploading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.upload),
          label: Text(isUploading ? 'Upload läuft...' : 'Bild wählen & hochladen'),
        ),
        if (progress > 0 && progress < 1) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text('${(progress * 100).toInt()}% hochgeladen'),
        ],
      ],
    );
  }

  Future<void> _pickAndUpload() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 3000,
      imageQuality: 92,
    );
    
    if (xFile == null) return;
    
    final file = File(xFile.path);
    final mime = 'image/jpeg'; // simpel; optional anhand Endung/Magic erkennen
    final repo = MediaRepository();

    setState(() {
      isUploading = true;
      progress = 0;
    });

    try {
      // 1) initiate
      final init = await repo.initiate(
        filename: xFile.name,
        mime: mime,
        bytes: await file.length(),
        visibility: 'internal',
        consentRequired: consentRequired,
        subjectName: subjectName.text.isEmpty ? null : subjectName.text,
        subjectContact: subjectContact.text.isEmpty ? null : subjectContact.text,
      );

      // 2) PUT upload with progress
      await repo.uploadPut(
        init.uploadUrl,
        file,
        contentType: mime,
        headers: init.headers,
        onProgress: (sent, total) {
          setState(() => progress = total > 0 ? sent / total : 0);
        },
      );

      // (optional: width/height aus XFile metadata – hier weggelassen)
      // 3) finalize
      final result = await repo.finalize(
        key: init.key,
        mime: mime,
        bytes: await file.length(),
        ownerType: widget.ownerType,
        ownerId: widget.ownerId,
        visibility: 'internal',
        consentRequired: consentRequired,
        subjectName: subjectName.text.isEmpty ? null : subjectName.text,
        subjectContact: subjectContact.text.isEmpty ? null : subjectContact.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload abgeschlossen')),
        );
        
        widget.onUploadComplete?.call(result);
        
        setState(() {
          progress = 0;
          isUploading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload fehlgeschlagen: $e'),
            backgroundColor: Colors.red,
          ),
        );
        
        setState(() {
          progress = 0;
          isUploading = false;
        });
      }
    }
  }
}