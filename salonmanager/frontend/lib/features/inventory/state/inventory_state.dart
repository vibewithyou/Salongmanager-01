import '../models/product.dart';
import '../models/stock_item.dart';
import '../models/movement.dart';
import '../models/supplier.dart';
import '../models/stock_location.dart';

class InventoryState {
  final bool loading;
  final List<Product> products;
  final List<StockItem> stock;
  final List<Movement> movements;
  final List<Supplier> suppliers;
  final List<StockLocation> locations;
  final int? nextProducts;
  final int? nextStock;
  final int? nextMovements;
  final int? nextSuppliers;

  const InventoryState({
    this.loading = false,
    this.products = const [],
    this.stock = const [],
    this.movements = const [],
    this.suppliers = const [],
    this.locations = const [],
    this.nextProducts = 1,
    this.nextStock = 1,
    this.nextMovements = 1,
    this.nextSuppliers = 1,
  });

  InventoryState copyWith({
    bool? loading,
    List<Product>? products,
    List<StockItem>? stock,
    List<Movement>? movements,
    List<Supplier>? suppliers,
    List<StockLocation>? locations,
    int? nextProducts,
    int? nextStock,
    int? nextMovements,
    int? nextSuppliers,
  }) =>
      InventoryState(
        loading: loading ?? this.loading,
        products: products ?? this.products,
        stock: stock ?? this.stock,
        movements: movements ?? this.movements,
        suppliers: suppliers ?? this.suppliers,
        locations: locations ?? this.locations,
        nextProducts: nextProducts,
        nextStock: nextStock,
        nextMovements: nextMovements,
        nextSuppliers: nextSuppliers,
      );
}