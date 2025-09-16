class LoyaltyCard {
  final int id;
  final int points;
  final Map<String, dynamic> meta;

  LoyaltyCard({
    required this.id,
    required this.points,
    this.meta = const {},
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> j) => LoyaltyCard(
        id: j['id'] as int,
        points: j['points'] as int? ?? 0,
        meta: Map<String, dynamic>.from(j['meta'] ?? {}),
      );
}

class LoyaltyTx {
  final int id;
  final int delta;
  final String? reason;
  final DateTime createdAt;

  LoyaltyTx({
    required this.id,
    required this.delta,
    this.reason,
    required this.createdAt,
  });

  factory LoyaltyTx.fromJson(Map<String, dynamic> j) => LoyaltyTx(
        id: j['id'] as int,
        delta: j['delta'] as int,
        reason: j['reason'] as String?,
        createdAt: DateTime.parse(j['created_at'] as String),
      );
}