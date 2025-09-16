import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gallery_photo.dart';
import '../models/suggested_service.dart';
import '../state/gallery_controller.dart';
import '../../booking/models/service.dart';
import '../../booking/models/stylist.dart';

class BookingFromPhotoDialog extends ConsumerStatefulWidget {
  final GalleryPhoto photo;

  const BookingFromPhotoDialog({
    Key? key,
    required this.photo,
  }) : super(key: key);

  @override
  ConsumerState<BookingFromPhotoDialog> createState() => _BookingFromPhotoDialogState();
}

class _BookingFromPhotoDialogState extends ConsumerState<BookingFromPhotoDialog> {
  List<SuggestedService>? _suggestedServices;
  SuggestedService? _selectedService;
  Stylist? _selectedStylist;
  DateTime? _selectedDateTime;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestedServices();
  }

  Future<void> _loadSuggestedServices() async {
    try {
      final services = await ref.read(galleryRepositoryProvider).getSuggestedServices(widget.photo.id);
      setState(() {
        _suggestedServices = services;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Book from this photo',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? _buildErrorState()
                      : _buildContent(),
            ),
            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: _canCreateBooking() ? _createBooking : null,
                    child: const Text('Create Booking'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading suggestions: $_error',
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadSuggestedServices,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo preview
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(widget.photo.imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Source indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.photo, color: Colors.blue.shade700),
                const SizedBox(width: 8),
                Text(
                  'Booking inspired by this photo',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Service selection
          Text(
            'Select Service',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (_suggestedServices != null && _suggestedServices!.isNotEmpty) ...[
            Text(
              'AI Suggested Services:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            ..._suggestedServices!.map((service) => _buildServiceCard(service, true)),
          ] else ...[
            Text(
              'No AI suggestions available. Please select from general services.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.orange.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 8),
            // Here you would typically load general services
            // For now, we'll show a placeholder
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('General services would be loaded here'),
            ),
          ],
          const SizedBox(height: 24),

          // Stylist selection (optional)
          Text(
            'Select Stylist (Optional)',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Stylist selection would be implemented here'),
          ),
          const SizedBox(height: 24),

          // Date/Time selection
          Text(
            'Select Date & Time',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Date/Time picker would be implemented here'),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(SuggestedService service, bool isSuggested) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: RadioListTile<SuggestedService>(
        title: Text(service.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (service.description.isNotEmpty) Text(service.description),
            Row(
              children: [
                Text('€${service.price.toStringAsFixed(2)}'),
                const SizedBox(width: 16),
                Text('${service.duration} min'),
                if (isSuggested) ...[
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'AI Suggested',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        value: service,
        groupValue: _selectedService,
        onChanged: (value) {
          setState(() {
            _selectedService = value;
          });
        },
      ),
    );
  }

  bool _canCreateBooking() {
    return _selectedService != null && _selectedDateTime != null;
  }

  Future<void> _createBooking() async {
    if (!_canCreateBooking()) return;

    try {
      // This would typically navigate to the booking wizard with pre-filled data
      // or create the booking directly
      Navigator.of(context).pop();
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
