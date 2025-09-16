class Shift {
  final int id;
  final int stylistId;
  final DateTime startAt;
  final DateTime endAt;
  final String status;
  final Map<String, dynamic> meta;

  Shift({
    required this.id,
    required this.stylistId,
    required this.startAt,
    required this.endAt,
    required this.status,
    this.meta = const {},
  });

  factory Shift.fromJson(Map<String, dynamic> j) => Shift(
        id: j['id'] as int,
        stylistId: j['stylist_id'] as int,
        startAt: DateTime.parse(j['start_at'] as String),
        endAt: DateTime.parse(j['end_at'] as String),
        status: j['status'] as String? ?? 'planned',
        meta: Map<String, dynamic>.from(j['meta'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stylist_id': stylistId,
        'start_at': startAt.toIso8601String(),
        'end_at': endAt.toIso8601String(),
        'status': status,
        'meta': meta,
      };
}