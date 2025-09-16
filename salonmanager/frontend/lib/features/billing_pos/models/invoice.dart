class Invoice {
  final int id;
  final String number;
  final DateTime issuedAt;
  final double totalNet;
  final double totalTax;
  final double totalGross;

  Invoice({
    required this.id,
    required this.number,
    required this.issuedAt,
    required this.totalNet,
    required this.totalTax,
    required this.totalGross,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
        id: json['id'],
        number: json['number'],
        issuedAt: DateTime.parse(json['issued_at']),
        totalNet: (json['total_net'] as num).toDouble(),
        totalTax: (json['total_tax'] as num).toDouble(),
        totalGross: (json['total_gross'] as num).toDouble(),
      );
}