import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/booking_wizard_controller.dart';
import '../data/booking_repository.dart';
import '../models/booking.dart';
import '../models/service.dart';
import '../models/stylist.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({super.key});

  @override
  ConsumerState<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends ConsumerState<BookingConfirmationScreen> {
  bool _isSubmitting = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(bookingWizardProvider);
    final controller = ref.read(bookingWizardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        centerTitle: true,
      ),
      body: _isSubmitting
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorState()
              : _buildConfirmationContent(context, state, controller),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error creating booking',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _error = null;
                });
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmationContent(BuildContext context, state, controller) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Review Your Booking',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please review your appointment details before confirming',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Services
          _buildSection(
            context,
            'Services',
            Icons.content_cut,
            _buildServicesList(state),
          ),
          const SizedBox(height: 16),

          // Stylist
          _buildSection(
            context,
            'Stylist',
            Icons.person,
            _buildStylistInfo(state),
          ),
          const SizedBox(height: 16),

          // Date & Time
          _buildSection(
            context,
            'Date & Time',
            Icons.schedule,
            _buildDateTimeInfo(state),
          ),
          const SizedBox(height: 16),

          // Additional Info
          if (state.notes.isNotEmpty || state.imagePaths.isNotEmpty) ...[
            _buildSection(
              context,
              'Additional Information',
              Icons.note,
              _buildAdditionalInfo(state),
            ),
            const SizedBox(height: 16),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _submitBooking(context, controller),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Confirm Booking',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, String title, IconData icon, Widget content) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(state) {
    // This is a stub - in a real app, you'd fetch service details
    return Column(
      children: state.serviceIds.map<Widget>((serviceId) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              const Icon(Icons.check, size: 16, color: Colors.green),
              const SizedBox(width: 8),
              Text('Service #$serviceId'), // Stub
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStylistInfo(state) {
    if (state.stylistId == null) {
      return const Text('No preference - we\'ll assign the best available stylist');
    }
    return Text('Stylist #${state.stylistId}'); // Stub
  }

  Widget _buildDateTimeInfo(state) {
    if (state.startAt == null) {
      return const Text('No date/time selected');
    }
    return Text(
      '${state.startAt!.day}/${state.startAt!.month}/${state.startAt!.year} at ${state.startAt!.hour.toString().padLeft(2, '0')}:${state.startAt!.minute.toString().padLeft(2, '0')}',
    );
  }

  Widget _buildAdditionalInfo(state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (state.notes.isNotEmpty) ...[
          const Text('Notes:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(state.notes),
          const SizedBox(height: 12),
        ],
        if (state.imagePaths.isNotEmpty) ...[
          const Text('Reference Images:', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text('${state.imagePaths.length} image(s) uploaded'),
        ],
      ],
    );
  }

  Future<void> _submitBooking(BuildContext context, controller) async {
    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final repository = BookingRepository();
      final booking = await repository.createBooking(ref.read(bookingWizardProvider));
      
      // Reset wizard state
      controller.reset();
      
      // Show success dialog
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Booking Confirmed!'),
            content: Text('Your appointment has been booked successfully. Booking ID: ${booking.id}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  Navigator.of(context).pop(); // Go back to previous screen
                },
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isSubmitting = false;
      });
    }
  }
}