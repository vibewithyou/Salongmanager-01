class Customer {
  final int id;
  final String name;
  final String email;

  Customer({
    required this.id,
    required this.name,
    required this.email,
  });

  factory Customer.fromJson(Map<String, dynamic> j) => Customer(
        id: j['id'] as int,
        name: j['name'] ?? '',
        email: j['email'] ?? '',
      );
}