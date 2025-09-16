class CartItem {
  final String type; // service|product|custom
  final int? referenceId;
  final String name;
  final int qty;
  final double unitNet;
  final double taxRate;
  final Map<String, dynamic>? discount; // {'percent':10} or 5.0

  CartItem({
    required this.type,
    this.referenceId,
    required this.name,
    this.qty = 1,
    required this.unitNet,
    required this.taxRate,
    this.discount,
  });

  Map<String, dynamic> toLine() => {
        'type': type,
        'reference_id': referenceId,
        'name': name,
        'qty': qty,
        'unit_net': unitNet,
        'tax_rate': taxRate,
        if (discount != null) 'discount': discount,
      };
}