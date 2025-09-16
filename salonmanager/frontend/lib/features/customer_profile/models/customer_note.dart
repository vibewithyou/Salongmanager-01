class CustomerNote {
  final int id;
  final int customerId;
  final int authorId;
  final String note;
  final DateTime createdAt;

  CustomerNote({
    required this.id,
    required this.customerId,
    required this.authorId,
    required this.note,
    required this.createdAt,
  });

  factory CustomerNote.fromJson(Map<String, dynamic> j) => CustomerNote(
        id: j['id'] as int,
        customerId: j['customer_id'] as int,
        authorId: j['author_id'] as int,
        note: j['note'] ?? '',
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}