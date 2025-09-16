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

  Future<Booking> createBooking(BookingWizardState state) async {
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

  Future<List<Booking>> getBookings() async {
    final response = await _dio.get('/booking');
    return (response.data['data'] as List)
        .map((json) => Booking.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<Booking> confirmBooking(int bookingId) async {
    final response = await _dio.post('/booking/$bookingId/confirm');
    return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<Booking> declineBooking(int bookingId) async {
    final response = await _dio.post('/booking/$bookingId/decline');
    return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
  }

  Future<Booking> cancelBooking(int bookingId) async {
    final response = await _dio.post('/booking/$bookingId/cancel');
    return Booking.fromJson(response.data['booking'] as Map<String, dynamic>);
  }
}