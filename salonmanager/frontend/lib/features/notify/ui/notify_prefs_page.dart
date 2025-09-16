import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/notify_controller.dart';

const _events = [
  'booking.confirmed','booking.declined','booking.canceled',
  'pos.invoice.paid',
  'media.consent.requested'
];
const _channels = ['mail','sms']; // webhook hier nicht für user-level

class NotifyPrefsPage extends ConsumerWidget {
  const NotifyPrefsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(notifyControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Benachrichtigungen')),
      body: s.loading ? const Center(child: CircularProgressIndicator()) :
      ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _events.length,
        separatorBuilder: (_, __)=> const Divider(),
        itemBuilder: (ctx,i){
          final ev = _events[i];
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(ev, style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 16,
              children: _channels.map((ch){
                final enabled = s.prefs.any((p)=>p['event']==ev && p['channel']==ch && p['enabled']==true);
                return FilterChip(
                  label: Text(ch.toUpperCase()),
                  selected: enabled,
                  onSelected: (v)=> ref.read(notifyControllerProvider.notifier).toggle(ev, ch, v),
                );
              }).toList(),
            ),
          ]);
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton.icon(
            onPressed: ()=> ref.read(notifyControllerProvider.notifier).save().then((_){
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Einstellungen gespeichert.')));
            }),
            icon: const Icon(Icons.save),
            label: const Text('Speichern'),
          ),
        ),
      ),
    );
  }
}