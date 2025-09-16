class Supplier {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final Map<String, dynamic>? address;
  final Map<String, dynamic>? meta;

  Supplier({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.meta,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) => Supplier(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    phone: json['phone'],
    address: json['address'] != null ? Map<String, dynamic>.from(json['address']) : null,
    meta: json['meta'] != null ? Map<String, dynamic>.from(json['meta']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'meta': meta,
  };
}