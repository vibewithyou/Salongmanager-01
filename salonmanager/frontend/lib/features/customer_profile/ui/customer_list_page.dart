import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../state/customer_list_controller.dart';

class CustomerListPage extends ConsumerWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(customerListControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Kunden')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Suche nach Name oder E-Mail',
              ),
              onSubmitted: (v) => ref.read(customerListControllerProvider.notifier).setSearch(v),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: s.customers.length + (s.nextPage != null ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i < s.customers.length) {
                  final c = s.customers[i];
                  return ListTile(
                    title: Text(c.name),
                    subtitle: Text(c.email),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push('/customers/${c.id}'),
                  );
                } else {
                  // load more
                  ref.read(customerListControllerProvider.notifier).loadMore();
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}