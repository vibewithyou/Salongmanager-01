import 'package:dio/dio.dart';
import '../../../services/api/dio_client.dart';
import '../models/booking.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../state/booking_wizard_state.dart';

class BookingRepository {
  final Dio _dio = ApiClient.build();

  Future<List<Service>> getServices() async {
    final response = await _dio.get('/services');
    return (response.data['data'] as List)
        .map((json) => Service.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<Stylist>> getStylists() async {
    final response = await _dio.get('/stylists');
    return (response.data['data'] as List)
        .map((json) => Stylist.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String,dynamic>> createBooking({
    required int customerId,
    required int stylistId,
    required int serviceId,
    required DateTime startAt,
    required int durationMin,
    int bufferBefore = 0,
    int bufferAfter = 0,
    String? note,
    List<int>? mediaIds,
    bool suggestIfConflict = true,
  }) async {
    try {
      final r = await _dio.post('/v1/bookings', data: {
        'customer_id': customerId,
        'stylist_id': stylistId,
        'service_id': serviceId,
        'start_at': startAt.toIso8601String(),
        'duration': durationMin,
        'buffer_before': bufferBefore,
        'buffer_after': bufferAfter,
        'note': note,
        'media_ids': mediaIds ?? [],
        'suggest_if_conflict': suggestIfConflict,
      });
      return {'ok': true, 'booking': r.data['booking']};
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return {'ok': false, 'conflict': true, 'suggestions': e.response?.data['suggestions'] ?? []};
      }
      rethrow;
    }
  }

  // Legacy method for backward compatibility
  Future<Booking> createBooking_old(BookingWizardState state) async {
    final data = {
      'services': state.serviceIds.map((id) => {'id': id}).toList(),
      'stylist_id': state.stylistId,
      'start_at': state.startAt?.toIso8601String(),
      'notes': state.notes,
      'images': state.imagePaths, // TODO: real upload
    };

    final response = await _dio.post('/booking', data: data);
    return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<void> updateStatus(int bookingId, String action, {String? reason}) async {
    await _dio.post('/v1/bookings/$bookingId/status', data: {'action': action, 'reason': reason});
  }

  Future<void> attachMedia(int bookingId, List<int> mediaIds) async {
    await _dio.post('/v1/bookings/$bookingId/media', data: {'media_ids': mediaIds});
  }

  Future<List<Booking>> getBookings() async {
    final response = await _dio.get('/booking');
    return (response.data['data'] as List)
        .map((json) => Booking.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> confirmBooking(int bookingId) async {
    await updateStatus(bookingId, 'confirm');
    final response = await _dio.get('/booking/$bookingId');
    return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<Booking> declineBooking(int bookingId, {String? reason}) async {
    await updateStatus(bookingId, 'decline', reason: reason);
    final response = await _dio.get('/booking/$bookingId');
    return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> cancelBooking(int bookingId, {String? reason}) async {
    final response = await _dio.post('/v1/bookings/$bookingId/status', 
      data: {'action': 'cancel', 'reason': reason}
    );
    return {
      'booking': response.data['booking'],
      'fee_rate': response.data['fee_rate'] ?? 0.0,
    };
  }
}