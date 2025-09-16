class PhotoStats {
  final int likes;
  final bool isLiked;
  final bool isFavorited;

  PhotoStats({
    required this.likes,
    required this.isLiked,
    required this.isFavorited,
  });

  factory PhotoStats.fromJson(Map<String, dynamic> json) {
    return PhotoStats(
      likes: json['likes'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isFavorited: json['is_favorited'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'likes': likes,
      'is_liked': isLiked,
      'is_favorited': isFavorited,
    };
  }

  PhotoStats copyWith({
    int? likes,
    bool? isLiked,
    bool? isFavorited,
  }) {
    return PhotoStats(
      likes: likes ?? this.likes,
      isLiked: isLiked ?? this.isLiked,
      isFavorited: isFavorited ?? this.isFavorited,
    );
  }
}
