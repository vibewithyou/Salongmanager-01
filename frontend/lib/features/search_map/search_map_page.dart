import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/api_client.dart';
import '../../common/widgets/optimized_image.dart';

class SearchMapPage extends StatefulWidget {
  const SearchMapPage({super.key});

  @override
  State<SearchMapPage> createState() => _SearchMapPageState();
}

class _SearchMapPageState extends State<SearchMapPage> {
  final ApiClient _apiClient = ApiClient();
  final MapController _mapController = MapController();
  
  List<dynamic> _salons = [];
  bool _loading = true;
  LatLng? _currentLocation;
  String _searchQuery = '';
  double _radiusKm = 10.0;
  double _ratingMin = 0.0;
  double _priceMin = 0.0;
  double _priceMax = 1000.0;
  bool _openNow = false;
  List<int> _selectedServices = [];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadSalons();
  }

  Future<void> _getCurrentLocation() async {
    // TODO: Implement actual geolocation
    // For now, use a default location (Berlin)
    setState(() {
      _currentLocation = const LatLng(52.5200, 13.4050);
    });
  }

  Future<void> _loadSalons() async {
    try {
      final queryParams = <String, dynamic>{
        'per_page': 50,
      };

      if (_currentLocation != null) {
        queryParams['lat'] = _currentLocation!.latitude;
        queryParams['lng'] = _currentLocation!.longitude;
        queryParams['radius_km'] = _radiusKm;
      }

      if (_searchQuery.isNotEmpty) {
        queryParams['q'] = _searchQuery;
      }

      if (_ratingMin > 0) {
        queryParams['rating_min'] = _ratingMin;
      }

      if (_priceMin > 0 || _priceMax < 1000) {
        queryParams['price_min'] = _priceMin;
        queryParams['price_max'] = _priceMax;
      }

      if (_openNow) {
        queryParams['open_now'] = true;
      }

      if (_selectedServices.isNotEmpty) {
        queryParams['services'] = _selectedServices;
      }

      final response = await _apiClient.get('/search/salons', queryParams: queryParams);
      setState(() {
        _salons = response.data['items'] as List<dynamic>? ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fehler beim Laden: $e')),
        );
      }
    }
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _FiltersSheet(
        radiusKm: _radiusKm,
        ratingMin: _ratingMin,
        priceMin: _priceMin,
        priceMax: _priceMax,
        openNow: _openNow,
        onApply: (filters) {
          setState(() {
            _radiusKm = filters['radiusKm'] as double;
            _ratingMin = filters['ratingMin'] as double;
            _priceMin = filters['priceMin'] as double;
            _priceMax = filters['priceMax'] as double;
            _openNow = filters['openNow'] as bool;
          });
          _loadSalons();
        },
      ),
    );
  }

  void _showSalonDetails(Map<String, dynamic> salon) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _SalonDetailsSheet(salon: salon),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salon-Suche'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Salon suchen...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _loadSalons();
              },
            ),
          ),

          // Map
          Expanded(
            flex: 2,
            child: _currentLocation == null
                ? const Center(child: CircularProgressIndicator())
                : FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: _currentLocation!,
                      zoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.salonmanager.app',
                      ),
                      MarkerLayer(
                        markers: _salons.map((salon) {
                          final coords = salon['location'];
                          if (coords == null) return null;
                          
                          final lat = coords['lat'] as double?;
                          final lng = coords['lng'] as double?;
                          if (lat == null || lng == null) return null;

                          return Marker(
                            point: LatLng(lat, lng),
                            width: 40,
                            height: 40,
                            child: GestureDetector(
                              onTap: () => _showSalonDetails(salon),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                child: const Icon(
                                  Icons.location_on,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          );
                        }).where((marker) => marker != null).cast<Marker>().toList(),
                      ),
                    ],
                  ),
          ),

          // Salon list
          Expanded(
            flex: 1,
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _salons.isEmpty
                    ? const Center(child: Text('Keine Salons gefunden'))
                    : ListView.builder(
                        itemCount: _salons.length,
                        itemBuilder: (context, index) {
                          final salon = _salons[index];
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: salon['logo_url'] != null
                                  ? NetworkImage(salon['logo_url'])
                                  : null,
                              child: salon['logo_url'] == null
                                  ? const Icon(Icons.business)
                                  : null,
                            ),
                            title: Text(salon['name'] ?? 'Unbekannt'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(salon['address'] ?? ''),
                                if (salon['rating_avg'] != null)
                                  Row(
                                    children: [
                                      const Icon(Icons.star, size: 16, color: Colors.amber),
                                      Text(' ${salon['rating_avg'].toStringAsFixed(1)}'),
                                    ],
                                  ),
                                if (salon['distance_km'] != null)
                                  Text('${salon['distance_km'].toStringAsFixed(1)} km entfernt'),
                              ],
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () => _showSalonDetails(salon),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _FiltersSheet extends StatefulWidget {
  final double radiusKm;
  final double ratingMin;
  final double priceMin;
  final double priceMax;
  final bool openNow;
  final Function(Map<String, dynamic>) onApply;

  const _FiltersSheet({
    required this.radiusKm,
    required this.ratingMin,
    required this.priceMin,
    required this.priceMax,
    required this.openNow,
    required this.onApply,
  });

  @override
  State<_FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends State<_FiltersSheet> {
  late double _radiusKm;
  late double _ratingMin;
  late double _priceMin;
  late double _priceMax;
  late bool _openNow;

  @override
  void initState() {
    super.initState();
    _radiusKm = widget.radiusKm;
    _ratingMin = widget.ratingMin;
    _priceMin = widget.priceMin;
    _priceMax = widget.priceMax;
    _openNow = widget.openNow;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Filter', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          
          // Radius
          Text('Radius: ${_radiusKm.toStringAsFixed(1)} km'),
          Slider(
            value: _radiusKm,
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: (value) => setState(() => _radiusKm = value),
          ),
          
          // Rating
          Text('Mindestbewertung: ${_ratingMin.toStringAsFixed(1)}'),
          Slider(
            value: _ratingMin,
            min: 0,
            max: 5,
            divisions: 50,
            onChanged: (value) => setState(() => _ratingMin = value),
          ),
          
          // Price range
          Text('Preisbereich: €${_priceMin.toStringAsFixed(0)} - €${_priceMax.toStringAsFixed(0)}'),
          RangeSlider(
            values: RangeValues(_priceMin, _priceMax),
            min: 0,
            max: 1000,
            divisions: 100,
            onChanged: (values) => setState(() {
              _priceMin = values.start;
              _priceMax = values.end;
            }),
          ),
          
          // Open now
          CheckboxListTile(
            title: const Text('Jetzt geöffnet'),
            value: _openNow,
            onChanged: (value) => setState(() => _openNow = value ?? false),
          ),
          
          const SizedBox(height: 16),
          
          // Apply button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply({
                  'radiusKm': _radiusKm,
                  'ratingMin': _ratingMin,
                  'priceMin': _priceMin,
                  'priceMax': _priceMax,
                  'openNow': _openNow,
                });
                Navigator.pop(context);
              },
              child: const Text('Filter anwenden'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SalonDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> salon;

  const _SalonDetailsSheet({required this.salon});

  Future<void> _openDirections() async {
    final coords = salon['location'];
    if (coords == null) return;
    
    final lat = coords['lat'] as double?;
    final lng = coords['lng'] as double?;
    if (lat == null || lng == null) return;

    final url = 'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: salon['logo_url'] != null
                    ? NetworkImage(salon['logo_url'])
                    : null,
                child: salon['logo_url'] == null
                    ? const Icon(Icons.business, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      salon['name'] ?? 'Unbekannt',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    if (salon['rating_avg'] != null)
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text(' ${salon['rating_avg'].toStringAsFixed(1)}'),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          if (salon['address'] != null)
            Text('Adresse: ${salon['address']}'),
          
          if (salon['phone'] != null)
            Text('Telefon: ${salon['phone']}'),
          
          if (salon['distance_km'] != null)
            Text('Entfernung: ${salon['distance_km'].toStringAsFixed(1)} km'),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openDirections,
                  icon: const Icon(Icons.directions),
                  label: const Text('Route'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Navigate to booking
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Termin buchen'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
