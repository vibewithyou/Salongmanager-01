import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/booking_wizard_controller.dart';
import '../data/booking_repository.dart';
import '../models/stylist.dart';

class StylistSelectionStep extends ConsumerStatefulWidget {
  const StylistSelectionStep({super.key});

  @override
  ConsumerState<StylistSelectionStep> createState() => _StylistSelectionStepState();
}

class _StylistSelectionStepState extends ConsumerState<StylistSelectionStep> {
  List<Stylist> _stylists = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadStylists();
  }

  Future<void> _loadStylists() async {
    try {
      final repository = BookingRepository();
      final stylists = await repository.getStylists();
      setState(() {
        _stylists = stylists;
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
            Text('Error loading stylists: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStylists,
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
          'Choose Stylist',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Select your preferred stylist or let us assign one for you',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 24),
        
        // No preference option
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: RadioListTile<int?>(
            title: const Text(
              'No Preference',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: const Text('We\'ll assign the best available stylist'),
            value: null,
            groupValue: state.stylistId,
            onChanged: (int? value) {
              controller.setStylist(value);
            },
          ),
        ),
        
        // Stylist options
        Expanded(
          child: ListView.builder(
            itemCount: _stylists.length,
            itemBuilder: (context, index) {
              final stylist = _stylists[index];
              final isSelected = state.stylistId == stylist.id;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: RadioListTile<int>(
                  title: Text(
                    stylist.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: stylist.skills != null && stylist.skills!.isNotEmpty
                      ? Text('Specialties: ${stylist.skills!.join(', ')}')
                      : null,
                  value: stylist.id,
                  groupValue: state.stylistId,
                  onChanged: (int? value) {
                    controller.setStylist(value);
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