# Media Upload System Implementation

This document describes the implementation of the secure media upload system with S3/MinIO presigned URLs, DSGVO consent handling, thumbnails, and retention policies.

## Backend (Laravel 12)

### Configuration

#### Filesystems Configuration
- **File**: `backend/config/filesystems.php`
- **Media Disk**: Configured for S3/MinIO with presigned URL support
- **Environment Variables**: See `.env.example` for required configuration

#### Environment Variables
```env
# Media Upload Configuration (S3/MinIO)
MEDIA_AWS_KEY=changeme
MEDIA_AWS_SECRET=changeme
MEDIA_AWS_REGION=eu-central-1
MEDIA_AWS_BUCKET=sm-media
MEDIA_ENDPOINT=https://minio.local
MEDIA_URL=https://cdn.salongmanager.app
MEDIA_PATH_STYLE=true
```

### Database Schema

#### Media Files Table
- **Migration**: `2025_09_16_800000_create_media_files_table.php`
- **Features**:
  - Polymorphic ownership (owner_type/owner_id)
  - DSGVO consent fields (consent_required, consent_status, subject_user_id, etc.)
  - Retention management (retention_until)
  - Visibility levels (public/internal/private)
  - Variants storage (thumbnails, WebP)
  - EXIF data storage

#### Gallery Integration
- **Migration**: `2025_09_16_800010_alter_gallery_photos_media_fk.php`
- **Feature**: Links gallery photos to media files via `media_file_id`

### API Endpoints

#### Upload Flow
1. **POST** `/api/v1/media/uploads/initiate`
   - Generates presigned URL for direct S3/MinIO upload
   - 10-minute expiration
   - Returns upload URL, key, and headers

2. **POST** `/api/v1/media/uploads/finalize`
   - Creates media file record
   - Queues thumbnail generation job
   - Handles consent and retention logic

#### File Management
- **GET** `/api/v1/media/files/{file}` - Get file metadata
- **DELETE** `/api/v1/media/files/{file}` - Soft delete file

### Background Processing

#### Thumbnail Generation
- **Job**: `ProcessImageJob`
- **Features**:
  - Creates 480px thumbnails
  - Generates WebP variants
  - Extracts EXIF data
  - Uses Intervention Image library

#### Retention Cleanup
- **Command**: `MediaPurgeExpired`
- **Schedule**: Daily at 3:30 AM
- **Logic**: Deletes files with expired retention or revoked consent

### Security & Compliance

#### DSGVO Compliance
- **Consent Status**: unknown → requested → approved/revoked
- **Retention**: 12 months default for consent-required files
- **Subject Data**: Name and contact information storage
- **Audit Trail**: All operations logged

#### Access Control
- **Policy**: `MediaFilePolicy`
- **Public Files**: Visible to all
- **Internal Files**: Staff only
- **Private Files**: Owner/Manager only

## Frontend (Flutter)

### Dependencies
- `image_picker: ^1.0.7` - Image selection
- `dio: ^5.5.0` - HTTP client (already present)

### Components

#### MediaRepository
- **File**: `lib/features/media/data/media_repository.dart`
- **Features**:
  - Initiate upload with presigned URL
  - Direct S3/MinIO upload with progress
  - Finalize upload and create record
  - File management operations

#### MediaUploader Widget
- **File**: `lib/features/media/ui/media_uploader.dart`
- **Features**:
  - Image picker integration
  - Consent form handling
  - Upload progress indication
  - Error handling and user feedback

#### Gallery Form Example
- **File**: `lib/features/media/ui/gallery_form_example.dart`
- **Features**:
  - Complete upload workflow example
  - Multiple file upload support
  - Form validation

## Usage Examples

### Backend - Creating a Media File
```php
// Initiate upload
$response = $this->post('/api/v1/media/uploads/initiate', [
    'filename' => 'photo.jpg',
    'mime' => 'image/jpeg',
    'bytes' => 1024000,
    'consent_required' => true,
    'subject_name' => 'John Doe',
    'subject_contact' => 'john@example.com'
]);

// Upload to presigned URL (client-side)
// Then finalize
$response = $this->post('/api/v1/media/uploads/finalize', [
    'key' => $uploadKey,
    'mime' => 'image/jpeg',
    'bytes' => 1024000,
    'owner_type' => 'GalleryPhoto',
    'owner_id' => 1,
    'consent_required' => true,
    'subject_name' => 'John Doe',
    'subject_contact' => 'john@example.com'
]);
```

### Frontend - Using MediaUploader
```dart
MediaUploader(
  ownerType: 'GalleryPhoto',
  ownerId: 1,
  consentRequiredDefault: false,
  onUploadComplete: (fileData) {
    print('Uploaded file: ${fileData['id']}');
  },
)
```

## Security Considerations

1. **Presigned URLs**: 10-minute expiration prevents abuse
2. **File Validation**: MIME type and size validation
3. **Access Control**: Role-based permissions
4. **Consent Management**: DSGVO-compliant data handling
5. **Retention Policies**: Automatic cleanup of expired files

## Dependencies

### Backend
- `aws/aws-sdk-php: ^3.0` - S3/MinIO integration
- `intervention/image: ^3.0` - Image processing

### Frontend
- `image_picker: ^1.0.7` - Image selection
- `dio: ^5.5.0` - HTTP client

## Deployment Notes

1. Configure S3/MinIO credentials in environment
2. Run migrations to create media_files table
3. Set up queue worker for thumbnail processing
4. Configure scheduled task for retention cleanup
5. Update Flutter dependencies

## Testing

The system includes comprehensive error handling and validation:
- File size limits (100MB max)
- MIME type validation
- Consent requirement validation
- Network error handling
- Progress indication

## Future Enhancements

1. **Video Support**: Extend to handle video files
2. **Advanced Processing**: Face detection, content moderation
3. **CDN Integration**: CloudFront or similar
4. **Batch Operations**: Bulk upload and processing
5. **Analytics**: Upload metrics and usage tracking