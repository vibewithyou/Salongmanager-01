import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/pos_controller.dart';
import '../models/cart_item.dart';

class PosPage extends ConsumerWidget {
  const PosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(posControllerProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Kasse')),
      body: Row(children: [
        // Left: simple item palette (placeholder)
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _ItemButton(
                label: 'Haarschnitt',
                onTap: () => ref.read(posControllerProvider.notifier).addItem(
                  CartItem(
                    type: 'service',
                    referenceId: 1,
                    name: 'Haarschnitt',
                    unitNet: 30,
                    taxRate: 19,
                  ),
                ),
              ),
              _ItemButton(
                label: 'Farbe',
                onTap: () => ref.read(posControllerProvider.notifier).addItem(
                  CartItem(
                    type: 'service',
                    referenceId: 2,
                    name: 'Farbe',
                    unitNet: 45,
                    taxRate: 19,
                  ),
                ),
              ),
              _ItemButton(
                label: 'Shampoo',
                onTap: () => ref.read(posControllerProvider.notifier).addItem(
                  CartItem(
                    type: 'product',
                    referenceId: 101,
                    name: 'Shampoo 250ml',
                    unitNet: 10,
                    taxRate: 19,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Right: cart
        Expanded(
          child: Column(children: [
            Expanded(
              child: ListView.builder(
                itemCount: state.cart.length,
                itemBuilder: (ctx, i) {
                  final item = state.cart[i];
                  return ListTile(
                    title: Text('${item.name} x${item.qty}'),
                    subtitle: Text(
                        '€ ${item.unitNet.toStringAsFixed(2)} • ${item.taxRate.toStringAsFixed(0)}%'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => ref
                          .read(posControllerProvider.notifier)
                          .removeItem(i),
                    ),
                  );
                },
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                _line('Netto', state.totalNet),
                _line('Steuer', state.totalTax),
                _line('Brutto', state.totalGross, isBold: true),
                const SizedBox(height: 8),
                Row(children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.cart.isEmpty || state.paying
                          ? null
                          : () async {
                              final invoice = await ref
                                  .read(posControllerProvider.notifier)
                                  .checkout(method: 'cash');
                              if (context.mounted) {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Rechnung bezahlt'),
                                    content: Text(
                                        'Nummer: ${invoice.number}\nSumme: € ${invoice.totalGross.toStringAsFixed(2)}'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('OK'),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                      child: state.paying
                          ? const CircularProgressIndicator()
                          : const Text('Bar kassieren'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: state.cart.isEmpty || state.paying
                          ? null
                          : () async {
                              // TODO: external card provider stub
                              final invoice = await ref
                                  .read(posControllerProvider.notifier)
                                  .checkout(method: 'card');
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Kartenzahlung gebucht: ${invoice.number}'),
                                  ),
                                );
                              }
                            },
                      child: const Text('Karte'),
                    ),
                  ),
                ]),
              ]),
            ),
          ]),
        ),
      ]),
    );
  }

  Widget _line(String label, double value, {bool isBold = false}) {
    final style = isBold ? const TextStyle(fontWeight: FontWeight.bold) : null;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text('€ ${value.toStringAsFixed(2)}', style: style),
      ],
    );
  }
}

class _ItemButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ItemButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: const Icon(Icons.add),
        onTap: onTap,
      ),
    );
  }
}