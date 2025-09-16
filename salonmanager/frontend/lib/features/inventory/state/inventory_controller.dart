import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/inventory_repository.dart';
import 'inventory_state.dart';

final inventoryRepositoryProvider = Provider<InventoryRepository>((_) => InventoryRepository());

final inventoryControllerProvider = StateNotifierProvider<InventoryController, InventoryState>(
    (ref) => InventoryController(ref.read(inventoryRepositoryProvider)));

class InventoryController extends StateNotifier<InventoryState> {
  final InventoryRepository _repo;

  InventoryController(this._repo) : super(const InventoryState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(
      loading: true,
      products: [],
      stock: [],
      movements: [],
      suppliers: [],
      locations: [],
      nextProducts: 1,
      nextStock: 1,
      nextMovements: 1,
      nextSuppliers: 1,
    );
    await Future.wait([
      loadMoreProducts(),
      loadMoreStock(),
      loadMoreMovements(),
      loadMoreSuppliers(),
      loadLocations(),
    ]);
    state = state.copyWith(loading: false);
  }

  Future<void> loadMoreProducts({String? search}) async {
    if (state.nextProducts == null) return;
    final res = await _repo.fetchProducts(page: state.nextProducts!, search: search);
    state = state.copyWith(
      products: [...state.products, ...res.items],
      nextProducts: res.nextPage,
    );
  }

  Future<void> loadMoreStock() async {
    if (state.nextStock == null) return;
    final res = await _repo.fetchStock(page: state.nextStock!);
    state = state.copyWith(
      stock: [...state.stock, ...res.items],
      nextStock: res.nextPage,
    );
  }

  Future<void> loadMoreMovements({int? productId}) async {
    if (state.nextMovements == null) return;
    final res = await _repo.movements(productId: productId, page: state.nextMovements!);
    state = state.copyWith(
      movements: [...state.movements, ...res.items],
      nextMovements: res.nextPage,
    );
  }

  Future<void> loadMoreSuppliers() async {
    if (state.nextSuppliers == null) return;
    final res = await _repo.fetchSuppliers(page: state.nextSuppliers!);
    state = state.copyWith(
      suppliers: [...state.suppliers, ...res.items],
      nextSuppliers: res.nextPage,
    );
  }

  Future<void> loadLocations() async {
    final locations = await _repo.fetchLocations();
    state = state.copyWith(locations: locations);
  }

  Future<void> inbound({
    required int productId,
    required int locationId,
    required int qty,
    String? note,
  }) async {
    await _repo.inbound(
      productId: productId,
      locationId: locationId,
      qty: qty,
      note: note,
    );
    await refresh();
  }

  Future<void> outbound({
    required int productId,
    required int locationId,
    required int qty,
    String? note,
  }) async {
    await _repo.outbound(
      productId: productId,
      locationId: locationId,
      qty: qty,
      note: note,
    );
    await refresh();
  }

  Future<void> transfer({
    required int productId,
    required int fromLocationId,
    required int toLocationId,
    required int qty,
    String? note,
  }) async {
    await _repo.transfer(
      productId: productId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      qty: qty,
      note: note,
    );
    await refresh();
  }

  Future<void> upsertProduct(Map<String, dynamic> payload, {int? id}) async {
    await _repo.upsertProduct(payload, id: id);
    await refresh();
  }

  Future<void> upsertSupplier(Map<String, dynamic> payload, {int? id}) async {
    await _repo.upsertSupplier(payload, id: id);
    await refresh();
  }

  Future<void> upsertLocation(Map<String, dynamic> payload, {int? id}) async {
    await _repo.upsertLocation(payload, id: id);
    await refresh();
  }
}