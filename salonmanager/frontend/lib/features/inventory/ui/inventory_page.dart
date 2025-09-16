import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/inventory_controller.dart';
import '../models/product.dart';
import '../models/stock_item.dart';
import '../models/movement.dart';
import '../models/supplier.dart';
import '../models/stock_location.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(inventoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(inventoryControllerProvider.notifier).refresh(),
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator())
          : DefaultTabController(
              length: 4,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'Produkte'),
                      Tab(text: 'Bestände'),
                      Tab(text: 'Bewegungen'),
                      Tab(text: 'Lieferanten'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _ProductsTab(products: state.products),
                        _StockTab(items: state.stock),
                        _MovementsTab(movements: state.movements),
                        _SuppliersTab(suppliers: state.suppliers),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openInboundDialog(context, ref),
        icon: const Icon(Icons.move_to_inbox),
        label: const Text('Wareneingang'),
      ),
    );
  }

  void _openInboundDialog(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final productIdController = TextEditingController();
    final locationIdController = TextEditingController();
    final qtyController = TextEditingController(text: '1');
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Wareneingang'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: productIdController,
                decoration: const InputDecoration(labelText: 'Produkt ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Pflicht' : null,
              ),
              TextFormField(
                controller: locationIdController,
                decoration: const InputDecoration(labelText: 'Lagerort ID'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Pflicht' : null,
              ),
              TextFormField(
                controller: qtyController,
                decoration: const InputDecoration(labelText: 'Menge'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Pflicht' : null,
              ),
              TextFormField(
                controller: noteController,
                decoration: const InputDecoration(labelText: 'Notiz (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              await ref.read(inventoryControllerProvider.notifier).inbound(
                    productId: int.parse(productIdController.text),
                    locationId: int.parse(locationIdController.text),
                    qty: int.parse(qtyController.text),
                    note: noteController.text.isEmpty ? null : noteController.text,
                  );
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
            },
            child: const Text('Buchen'),
          ),
        ],
      ),
    );
  }
}

class _ProductsTab extends StatelessWidget {
  final List<Product> products;
  const _ProductsTab({required this.products});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: products.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final product = products[i];
        return ListTile(
          title: Text(product.name),
          subtitle: Text(
            'SKU: ${product.sku} • MwSt ${product.taxRate.toStringAsFixed(0)}% • Min: ${product.reorderPoint}',
          ),
          trailing: Text(
            product.grossPrice != null ? '€ ${product.grossPrice!.toStringAsFixed(2)}' : '',
          ),
        );
      },
    );
  }
}

class _StockTab extends StatelessWidget {
  final List<StockItem> items;
  const _StockTab({required this.items});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final item = items[i];
        final warn = item.qty < 0 ? Colors.red : null;
        return ListTile(
          title: Text('${item.productName} (${item.productSku})'),
          subtitle: Text('Lager: ${item.locationName}'),
          trailing: Text(
            'Qty: ${item.qty}',
            style: TextStyle(color: warn),
          ),
        );
      },
    );
  }
}

class _MovementsTab extends StatelessWidget {
  final List<Movement> movements;
  const _MovementsTab({required this.movements});

  @override
  Widget build(BuildContext context) {
    if (movements.isEmpty) {
      return const Center(child: Text('Keine Bewegungen gefunden'));
    }

    return ListView.separated(
      itemCount: movements.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final movement = movements[i];
        final isPositive = movement.delta > 0;
        return ListTile(
          title: Text('${movement.type.toUpperCase()} - ${isPositive ? '+' : ''}${movement.delta}'),
          subtitle: Text(
            'Produkt ID: ${movement.productId} • ${movement.movedAt.toString().substring(0, 16)}',
          ),
          trailing: Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.green : Colors.red,
          ),
        );
      },
    );
  }
}

class _SuppliersTab extends StatelessWidget {
  final List<Supplier> suppliers;
  const _SuppliersTab({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: suppliers.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final supplier = suppliers[i];
        return ListTile(
          title: Text(supplier.name),
          subtitle: Text(supplier.email ?? supplier.phone ?? ''),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        );
      },
    );
  }
}