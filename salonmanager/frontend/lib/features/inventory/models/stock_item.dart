class StockItem {
  final int id;
  final int productId;
  final String productName;
  final String productSku;
  final int locationId;
  final String locationName;
  final int qty;

  StockItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.locationId,
    required this.locationName,
    required this.qty,
  });

  factory StockItem.fromJson(Map<String, dynamic> json) => StockItem(
    id: json['id'],
    productId: json['product_id'],
    productName: json['product']['name'],
    productSku: json['product']['sku'],
    locationId: json['location_id'],
    locationName: json['location']['name'],
    qty: json['qty'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'product_id': productId,
    'product_name': productName,
    'product_sku': productSku,
    'location_id': locationId,
    'location_name': locationName,
    'qty': qty,
  };
}