import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/gallery_photo.dart';
import '../models/photo_stats.dart';
import '../models/suggested_service.dart';

class GalleryRepository {
  final String baseUrl;
  final String? authToken;

  GalleryRepository({
    required this.baseUrl,
    this.authToken,
  });

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (authToken != null) 'Authorization': 'Bearer $authToken',
  };

  Future<List<GalleryPhoto>> getPhotos({
    int? albumId,
    bool? approved,
    String? beforeAfterGroup,
  }) async {
    final queryParams = <String, String>{};
    if (albumId != null) queryParams['album_id'] = albumId.toString();
    if (approved != null) queryParams['approved'] = approved.toString();
    if (beforeAfterGroup != null) queryParams['before_after_group'] = beforeAfterGroup;

    final uri = Uri.parse('$baseUrl/api/v1/gallery/photos').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> photosData = data['data'] ?? [];
      return photosData.map((json) => GalleryPhoto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos: ${response.statusCode}');
    }
  }

  Future<GalleryPhoto> getPhoto(int photoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/gallery/photos/$photoId'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return GalleryPhoto.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load photo: ${response.statusCode}');
    }
  }

  Future<PhotoStats> getPhotoStats(int photoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/gallery/photos/$photoId/stats'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      return PhotoStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load photo stats: ${response.statusCode}');
    }
  }

  Future<PhotoStats> likePhoto(int photoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/gallery/photos/$photoId/like'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PhotoStats(
        likes: data['likes_count'],
        isLiked: data['liked'],
        isFavorited: false, // This endpoint doesn't return favorites info
      );
    } else {
      throw Exception('Failed to like photo: ${response.statusCode}');
    }
  }

  Future<PhotoStats> favoritePhoto(int photoId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/gallery/photos/$photoId/favorite'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PhotoStats(
        likes: 0, // This endpoint doesn't return likes info
        isLiked: false,
        isFavorited: data['favorited'],
      );
    } else {
      throw Exception('Failed to favorite photo: ${response.statusCode}');
    }
  }

  Future<List<GalleryPhoto>> getCustomerGallery(int customerId, {
    bool? approved,
    String? beforeAfterGroup,
  }) async {
    final queryParams = <String, String>{};
    if (approved != null) queryParams['approved'] = approved.toString();
    if (beforeAfterGroup != null) queryParams['before_after_group'] = beforeAfterGroup;

    final uri = Uri.parse('$baseUrl/api/v1/customers/$customerId/gallery').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final response = await http.get(uri, headers: _headers);
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> photosData = data['data'] ?? [];
      return photosData.map((json) => GalleryPhoto.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load customer gallery: ${response.statusCode}');
    }
  }

  Future<List<SuggestedService>> getSuggestedServices(int photoId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/gallery/photos/$photoId/suggested-services'),
      headers: _headers,
    );
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> servicesData = data['suggested_services'] ?? [];
      return servicesData.map((json) => SuggestedService.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load suggested services: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createBookingFromPhoto(int photoId, {
    required int serviceId,
    int? stylistId,
    DateTime? startAt,
  }) async {
    final body = {
      'service_id': serviceId,
      if (stylistId != null) 'stylist_id': stylistId,
      if (startAt != null) 'start_at': startAt.toIso8601String(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/bookings/from-photo/$photoId'),
      headers: _headers,
      body: json.encode(body),
    );
    
    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to create booking from photo: ${response.statusCode}');
    }
  }
}
