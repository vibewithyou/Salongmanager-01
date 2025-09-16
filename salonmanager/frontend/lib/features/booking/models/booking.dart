import 'service.dart';
import 'stylist.dart';

class Booking {
  final int id;
  final int salonId;
  final int customerId;
  final int? stylistId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final String? notes;
  final List<Service> services;
  final Stylist? stylist;
  final List<String> imagePaths;

  const Booking({
    required this.id,
    required this.salonId,
    required this.customerId,
    this.stylistId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.notes,
    this.services = const [],
    this.stylist,
    this.imagePaths = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      salonId: json['salon_id'] as int,
      customerId: json['customer_id'] as int,
      stylistId: json['stylist_id'] as int?,
      startAt: DateTime.parse(json['start_at'] as String),
      endAt: DateTime.parse(json['end_at'] as String),
      status: json['status'] as String,
      notes: json['notes'] as String?,
      services: json['services'] != null
          ? (json['services'] as List)
              .map((s) => Service.fromJson(s as Map<String, dynamic>))
              .toList()
          : [],
      stylist: json['stylist'] != null
          ? Stylist.fromJson(json['stylist'] as Map<String, dynamic>)
          : null,
      imagePaths: json['media'] != null
          ? (json['media'] as List)
              .map((m) => m['path'] as String)
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'customer_id': customerId,
      'stylist_id': stylistId,
      'start_at': startAt.toIso8601String(),
      'end_at': endAt.toIso8601String(),
      'status': status,
      'notes': notes,
      'services': services.map((s) => s.toJson()).toList(),
      'stylist': stylist?.toJson(),
      'image_paths': imagePaths,
    };
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isDeclined => status == 'declined';
  bool get isCanceled => status == 'canceled';
}