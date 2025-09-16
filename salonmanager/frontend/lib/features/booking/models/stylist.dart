class Stylist {
  final int id;
  final String displayName;
  final List<String>? skills;

  const Stylist({
    required this.id,
    required this.displayName,
    this.skills,
  });

  factory Stylist.fromJson(Map<String, dynamic> json) {
    return Stylist(
      id: json['id'] as int,
      displayName: json['display_name'] as String,
      skills: json['skills'] != null 
          ? List<String>.from(json['skills'] as List)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'display_name': displayName,
      'skills': skills,
    };
  }
}