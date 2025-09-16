class ContentBlock {
  final int id;
  final String type; // hero, text, gallery, cta, ...
  final String? title;
  final Map<String, dynamic> config;
  final bool isActive;
  final int position;

  ContentBlock({
    required this.id,
    required this.type,
    this.title,
    this.config = const {},
    required this.isActive,
    required this.position,
  });

  factory ContentBlock.fromJson(Map<String, dynamic> j) => ContentBlock(
    id: j['id'] as int,
    type: j['type'] as String,
    title: j['title'],
    config: Map<String,dynamic>.from(j['config'] ?? {}),
    isActive: j['is_active'] as bool? ?? true,
    position: j['position'] as int? ?? 0,
  );
}