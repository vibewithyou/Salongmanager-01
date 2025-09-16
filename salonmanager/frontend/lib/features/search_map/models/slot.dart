class Slot {
  final int stylistId;
  final DateTime startAt;
  final DateTime endAt;
  
  Slot({
    required this.stylistId, 
    required this.startAt, 
    required this.endAt
  });
  
  factory Slot.fromJson(Map<String,dynamic> j) => Slot(
    stylistId: j['stylist_id'] as int,
    startAt: DateTime.parse(j['start_at'] as String),
    endAt: DateTime.parse(j['end_at'] as String),
  );
}