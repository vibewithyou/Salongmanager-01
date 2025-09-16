import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/gallery_repository.dart';
import '../models/gallery_photo.dart';
import '../models/photo_stats.dart';
import '../models/suggested_service.dart';

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  // This would typically be injected from a higher level
  return GalleryRepository(
    baseUrl: 'https://api.salongmanager.app', // This should come from config
    authToken: null, // This should come from auth state
  );
});

final galleryPhotosProvider = FutureProvider.family<List<GalleryPhoto>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(galleryRepositoryProvider);
  return repository.getPhotos(
    albumId: params['albumId'] as int?,
    approved: params['approved'] as bool?,
    beforeAfterGroup: params['beforeAfterGroup'] as String?,
  );
});

final photoStatsProvider = FutureProvider.family<PhotoStats, int>((ref, photoId) async {
  final repository = ref.read(galleryRepositoryProvider);
  return repository.getPhotoStats(photoId);
});

final suggestedServicesProvider = FutureProvider.family<List<SuggestedService>, int>((ref, photoId) async {
  final repository = ref.read(galleryRepositoryProvider);
  return repository.getSuggestedServices(photoId);
});

final customerGalleryProvider = FutureProvider.family<List<GalleryPhoto>, Map<String, dynamic>>((ref, params) async {
  final repository = ref.read(galleryRepositoryProvider);
  return repository.getCustomerGallery(
    params['customerId'] as int,
    approved: params['approved'] as bool?,
    beforeAfterGroup: params['beforeAfterGroup'] as String?,
  );
});

class GalleryController extends StateNotifier<AsyncValue<List<GalleryPhoto>>> {
  final GalleryRepository _repository;

  GalleryController(this._repository) : super(const AsyncValue.loading());

  Future<void> loadPhotos({
    int? albumId,
    bool? approved,
    String? beforeAfterGroup,
  }) async {
    state = const AsyncValue.loading();
    try {
      final photos = await _repository.getPhotos(
        albumId: albumId,
        approved: approved,
        beforeAfterGroup: beforeAfterGroup,
      );
      state = AsyncValue.data(photos);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refresh() async {
    // Reload current photos
    await loadPhotos();
  }
}

final galleryControllerProvider = StateNotifierProvider<GalleryController, AsyncValue<List<GalleryPhoto>>>((ref) {
  final repository = ref.read(galleryRepositoryProvider);
  return GalleryController(repository);
});

class PhotoInteractionController extends StateNotifier<AsyncValue<PhotoStats>> {
  final GalleryRepository _repository;
  final int _photoId;

  PhotoInteractionController(this._repository, this._photoId) : super(const AsyncValue.loading()) {
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await _repository.getPhotoStats(_photoId);
      state = AsyncValue.data(stats);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleLike() async {
    if (state.hasValue) {
      final currentStats = state.value!;
      try {
        final newStats = await _repository.likePhoto(_photoId);
        state = AsyncValue.data(newStats);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }

  Future<void> toggleFavorite() async {
    if (state.hasValue) {
      final currentStats = state.value!;
      try {
        final newStats = await _repository.favoritePhoto(_photoId);
        state = AsyncValue.data(newStats);
      } catch (error, stackTrace) {
        state = AsyncValue.error(error, stackTrace);
      }
    }
  }
}

final photoInteractionProvider = StateNotifierProvider.family<PhotoInteractionController, AsyncValue<PhotoStats>, int>((ref, photoId) {
  final repository = ref.read(galleryRepositoryProvider);
  return PhotoInteractionController(repository, photoId);
});
