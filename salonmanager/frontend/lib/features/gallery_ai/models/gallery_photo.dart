class GalleryPhoto {
  final int id;
  final int salonId;
  final int? albumId;
  final int? customerId;
  final String path;
  final Map<String, dynamic>? variants;
  final String? beforeAfterGroup;
  final DateTime? approvedAt;
  final DateTime? rejectedAt;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? albumTitle;
  final String? albumVisibility;
  final String? customerName;
  final String? creatorName;

  GalleryPhoto({
    required this.id,
    required this.salonId,
    this.albumId,
    this.customerId,
    required this.path,
    this.variants,
    this.beforeAfterGroup,
    this.approvedAt,
    this.rejectedAt,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.albumTitle,
    this.albumVisibility,
    this.customerName,
    this.creatorName,
  });

  factory GalleryPhoto.fromJson(Map<String, dynamic> json) {
    return GalleryPhoto(
      id: json['id'],
      salonId: json['salon_id'],
      albumId: json['album_id'],
      customerId: json['customer_id'],
      path: json['path'],
      variants: json['variants'],
      beforeAfterGroup: json['before_after_group'],
      approvedAt: json['approved_at'] != null ? DateTime.parse(json['approved_at']) : null,
      rejectedAt: json['rejected_at'] != null ? DateTime.parse(json['rejected_at']) : null,
      createdBy: json['created_by'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      albumTitle: json['album']?['title'],
      albumVisibility: json['album']?['visibility'],
      customerName: json['customer']?['name'],
      creatorName: json['creator']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'salon_id': salonId,
      'album_id': albumId,
      'customer_id': customerId,
      'path': path,
      'variants': variants,
      'before_after_group': beforeAfterGroup,
      'approved_at': approvedAt?.toIso8601String(),
      'rejected_at': rejectedAt?.toIso8601String(),
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isApproved => approvedAt != null && rejectedAt == null;
  bool get isRejected => rejectedAt != null;

  String get imageUrl {
    // This would typically construct the full URL from the path
    // For now, return the path as-is
    return path;
  }

  String? get thumbnailUrl {
    if (variants != null && variants!['thumb'] != null) {
      return variants!['thumb']['path'] ?? variants!['thumb'];
    }
    return imageUrl;
  }
}
