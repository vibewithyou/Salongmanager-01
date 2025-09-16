import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/customer_detail_controller.dart';

class CustomerDetailPage extends ConsumerStatefulWidget {
  final int id;

  const CustomerDetailPage({super.key, required this.id});

  @override
  ConsumerState<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends ConsumerState<CustomerDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(customerDetailControllerProvider(widget.id));
    final c = s.customer;
    return Scaffold(
      appBar: AppBar(
        title: Text(c?.name ?? 'Kunde'),
        bottom: const TabBar(
          tabs: [
            Tab(text: 'Profil'),
            Tab(text: 'Notizen & Bilder'),
            Tab(text: 'Treue'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _ProfileTab(id: widget.id),
          _NotesTab(id: widget.id),
          _LoyaltyTab(id: widget.id),
        ],
      ),
    );
  }
}

class _ProfileTab extends ConsumerWidget {
  final int id;

  const _ProfileTab({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(customerDetailControllerProvider(id));
    final p = s.profile;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ListTile(
          title: const Text('E-Mail'),
          subtitle: Text(s.customer?.email ?? '–'),
        ),
        ListTile(
          title: const Text('Telefon'),
          subtitle: Text(p?.phone ?? '–'),
        ),
        ListTile(
          title: const Text('Bevorzugter Stylist'),
          subtitle: Text(p?.preferredStylist ?? '–'),
        ),
        // TODO: Edit-Form & Save -> updateProfile
      ],
    );
  }
}

class _NotesTab extends ConsumerStatefulWidget {
  final int id;

  const _NotesTab({required this.id});

  @override
  ConsumerState<_NotesTab> createState() => _NotesTabState();
}

class _NotesTabState extends ConsumerState<_NotesTab> {
  final _ctrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(customerDetailControllerProvider(widget.id));
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _ctrl,
                  decoration: const InputDecoration(hintText: 'Notiz hinzufügen'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  if (_ctrl.text.trim().isEmpty) return;
                  await ref
                      .read(customerDetailControllerProvider(widget.id).notifier)
                      .addNote(_ctrl.text.trim());
                  _ctrl.clear();
                },
                child: const Text('Speichern'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: s.notes.length,
            itemBuilder: (ctx, i) {
              final n = s.notes[i];
              return ListTile(
                leading: const Icon(Icons.note),
                title: Text(n.note),
                subtitle: Text(n.createdAt.toIso8601String()),
              );
            },
          ),
        ),
        // TODO: Bilder-Grid + Upload (separater Media-Slice)
      ],
    );
  }
}

class _LoyaltyTab extends ConsumerWidget {
  final int id;

  const _LoyaltyTab({required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(customerDetailControllerProvider(id));
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Punkte: ${s.card?.points ?? 0}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              ElevatedButton(
                onPressed: () => ref
                    .read(customerDetailControllerProvider(id).notifier)
                    .adjustPoints(10, reason: 'Service'),
                child: const Text('+10'),
              ),
              ElevatedButton(
                onPressed: () => ref
                    .read(customerDetailControllerProvider(id).notifier)
                    .adjustPoints(-10, reason: 'Korrektur'),
                child: const Text('-10'),
              ),
            ],
          ),
          const Divider(height: 24),
          const Text('Transaktionen'),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: s.txs.length,
              itemBuilder: (ctx, i) {
                final t = s.txs[i];
                return ListTile(
                  leading: CircleAvatar(
                    child: Text(t.delta >= 0 ? '+' : '-'),
                  ),
                  title: Text('${t.delta} • ${t.reason ?? '–'}'),
                  subtitle: Text(t.createdAt.toIso8601String()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}