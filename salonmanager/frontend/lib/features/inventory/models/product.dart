class Product {
  final int id;
  final String sku;
  final String name;
  final double taxRate;
  final int reorderPoint;
  final int reorderQty;
  final double? netPrice;
  final double? grossPrice;
  final String? description;
  final String? barcode;
  final int? supplierId;
  final Map<String, dynamic>? meta;

  Product({
    required this.id,
    required this.sku,
    required this.name,
    required this.taxRate,
    required this.reorderPoint,
    required this.reorderQty,
    this.netPrice,
    this.grossPrice,
    this.description,
    this.barcode,
    this.supplierId,
    this.meta,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    sku: json['sku'],
    name: json['name'],
    taxRate: (json['tax_rate'] as num).toDouble(),
    reorderPoint: json['reorder_point'] ?? 0,
    reorderQty: json['reorder_qty'] ?? 0,
    netPrice: (json['price']?['net_price'] as num?)?.toDouble(),
    grossPrice: (json['price']?['gross_price'] as num?)?.toDouble(),
    description: json['description'],
    barcode: json['barcode'],
    supplierId: json['supplier_id'],
    meta: json['meta'] != null ? Map<String, dynamic>.from(json['meta']) : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'sku': sku,
    'name': name,
    'tax_rate': taxRate,
    'reorder_point': reorderPoint,
    'reorder_qty': reorderQty,
    'net_price': netPrice,
    'gross_price': grossPrice,
    'description': description,
    'barcode': barcode,
    'supplier_id': supplierId,
    'meta': meta,
  };
}