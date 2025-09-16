class Absence {
  final int id;
  final int stylistId;
  final DateTime fromDate;
  final DateTime toDate;
  final String type;
  final String status;
  final String? note;

  Absence({
    required this.id,
    required this.stylistId,
    required this.fromDate,
    required this.toDate,
    required this.type,
    required this.status,
    this.note,
  });

  factory Absence.fromJson(Map<String, dynamic> j) => Absence(
        id: j['id'] as int,
        stylistId: j['stylist_id'] as int,
        fromDate: DateTime.parse(j['from_date'] as String),
        toDate: DateTime.parse(j['to_date'] as String),
        type: j['type'] as String,
        status: j['status'] as String,
        note: j['note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'stylist_id': stylistId,
        'from_date': fromDate.toIso8601String().split('T')[0],
        'to_date': toDate.toIso8601String().split('T')[0],
        'type': type,
        'status': status,
        'note': note,
      };
}