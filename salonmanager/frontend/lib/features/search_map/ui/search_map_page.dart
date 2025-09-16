import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../state/search_controller.dart';
import '../data/search_repository.dart';
import '../models/slot.dart';

class SearchMapPage extends ConsumerStatefulWidget {
  const SearchMapPage({super.key});
  @override
  ConsumerState<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends ConsumerState<SearchMapPage> {
  final _mapController = MapController();
  final _queryCtrl = TextEditingController();
  double _radius = 5;

  @override
  void initState() {
    super.initState();
    // Default center Berlin (TODO: geolocate user with permission)
    ref.read(searchControllerProvider.notifier).setLocation(52.5200, 13.4050);
    ref.read(searchControllerProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(searchControllerProvider);
    final center = LatLng(s.lat ?? 52.52, s.lng ?? 13.405);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Salons suchen'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _queryCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Suche (Name, Stadt, Tags)',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onSubmitted: (v) {
                    ref.read(searchControllerProvider.notifier).setQuery(v.trim());
                    ref.read(searchControllerProvider.notifier).refresh();
                  },
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Jetzt offen'),
                selected: s.openNow,
                onSelected: (v) {
                  ref.read(searchControllerProvider.notifier).setOpenNow(v);
                  ref.read(searchControllerProvider.notifier).refresh();
                },
              ),
            ]),
          ),
        ),
      ),
      body: Column(children: [
        // Map
        SizedBox(
          height: 300,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: 12,
              onTap: (tapPos, latlng) {
                ref.read(searchControllerProvider.notifier).setLocation(latlng.latitude, latlng.longitude);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'salonmanager.app',
              ),
              MarkerLayer(markers: s.hits.map((h) {
                return Marker(
                  point: LatLng(h.lat, h.lng),
                  width: 44, 
                  height: 44,
                  child: Tooltip(
                    message: h.name,
                    child: InkWell(
                      onTap: () {
                        // zoom & maybe open bottom sheet
                        _mapController.move(LatLng(h.lat, h.lng), 15);
                        _openDetailSheet(context, h.id, title: h.name);
                      },
                      child: const Icon(Icons.location_on, size: 36),
                    ),
                  ),
                );
              }).toList()),
            ],
          ),
        ),
        // Radius slider
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(children: [
            const Text('Radius'),
            Expanded(
              child: Slider(
                value: _radius, 
                min: 1, 
                max: 50, 
                divisions: 49,
                label: '${_radius.toStringAsFixed(0)} km',
                onChanged: (v) => setState(() => _radius = v),
                onChangeEnd: (v) {
                  ref.read(searchControllerProvider.notifier).setRadius(v);
                  ref.read(searchControllerProvider.notifier).refresh();
                },
              ),
            ),
          ]),
        ),
        const Divider(height: 1),
        // Results list
        Expanded(
          child: s.loading && s.hits.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: s.hits.length + (s.nextPage != null ? 1 : 0),
                  itemBuilder: (ctx, i) {
                    if (i < s.hits.length) {
                      final h = s.hits[i];
                      return Card(
                        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.store)),
                          title: Text(h.name),
                          subtitle: Text('${h.city ?? ''} ${h.zip ?? ''} • ${h.shortDesc ?? ''}'),
                          trailing: Text(h.distanceKm != null ? '${h.distanceKm!.toStringAsFixed(1)} km' : ''),
                          onTap: () => _openDetailSheet(context, h.id, title: h.name),
                        ),
                      );
                    } else {
                      ref.read(searchControllerProvider.notifier).loadMore();
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                  },
                ),
        ),
      ]),
    );
  }

  void _openDetailSheet(BuildContext context, int salonId, {required String title}) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => _SalonPreviewSheet(salonId: salonId, title: title),
    );
  }
}

class _SalonPreviewSheet extends ConsumerStatefulWidget {
  final int salonId;
  final String title;
  const _SalonPreviewSheet({required this.salonId, required this.title});
  @override
  ConsumerState<_SalonPreviewSheet> createState() => _SalonPreviewSheetState();
}

class _SalonPreviewSheetState extends ConsumerState<_SalonPreviewSheet> {
  List<Slot> slots = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    // Example: serviceId optional → hier Demo: null -> keine Slots
    try {
      // TODO: service selection UI – hier nehmen wir beispielhaft serviceId=1 wenn vorhanden
      final repo = ref.read(searchRepositoryProvider);
      final result = await repo.availability(salonId: widget.salonId, serviceId: 1, limit: 3);
      setState(() => slots = result);
    } catch (_) {}
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(widget.title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                if (slots.isEmpty) const Text('Keine freien Slots gefunden (nächste 14 Tage).'),
                if (slots.isNotEmpty)
                  Wrap(
                    spacing: 8, 
                    runSpacing: 8,
                    children: slots.map<Widget>((s) {
                      final start = s.startAt;
                      final hh = start.hour.toString().padLeft(2, '0');
                      final mm = start.minute.toString().padLeft(2, '0');
                      return OutlinedButton(
                        onPressed: () {
                          // TODO: jump to booking wizard prefilled
                          Navigator.pop(context);
                        },
                        child: Text('${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')} $hh:$mm'),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: navigate to salon page or booking
                      Navigator.pop(context);
                    },
                    child: const Text('Mehr anzeigen'),
                  ),
                )
              ]),
      ),
    );
  }
}