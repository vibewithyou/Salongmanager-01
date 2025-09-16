class CustomerProfile {
  final String? phone;
  final String? preferredStylist;
  final Map<String, dynamic> prefs;
  final Map<String, dynamic> address;

  CustomerProfile({
    this.phone,
    this.preferredStylist,
    this.prefs = const {},
    this.address = const {},
  });

  factory CustomerProfile.fromJson(Map<String, dynamic> j) => CustomerProfile(
        phone: j['phone'],
        preferredStylist: j['preferred_stylist'],
        prefs: Map<String, dynamic>.from(j['prefs'] ?? {}),
        address: Map<String, dynamic>.from(j['address'] ?? {}),
      );
}