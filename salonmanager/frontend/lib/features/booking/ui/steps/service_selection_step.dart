import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/booking_wizard_controller.dart';
import '../data/booking_repository.dart';
import '../models/service.dart';

class ServiceSelectionStep extends ConsumerStatefulWidget {
  const ServiceSelectionStep({super.key});

  @override
  ConsumerState<ServiceSelectionStep> createState() => _ServiceSelectionStepState();
}

class _ServiceSelectionStepState extends ConsumerState<ServiceSelectionStep> {
  List<Service> _services = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    try {
      final repository = BookingRepository();
      final services = await repository.getServices();
      setState(() {
        _services = services;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingWizardProvider);
    final controller = ref.read(bookingWizardProvider.notifier);

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text('Error loading services: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadServices,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Services',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Choose the services you would like to book',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.builder(
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final isSelected = state.serviceIds.contains(service.id);
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: CheckboxListTile(
                  title: Text(
                    service.name,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (service.description != null) ...[
                        const SizedBox(height: 4),
                        Text(service.description!),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('${service.baseDuration} min'),
                          const SizedBox(width: 16),
                          Icon(Icons.attach_money, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text('\$${service.basePrice.toStringAsFixed(2)}'),
                        ],
                      ),
                    ],
                  ),
                  value: isSelected,
                  onChanged: (bool? value) {
                    if (value == true) {
                      controller.setServices([...state.serviceIds, service.id]);
                    } else {
                      controller.setServices(
                        state.serviceIds.where((id) => id != service.id).toList(),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}