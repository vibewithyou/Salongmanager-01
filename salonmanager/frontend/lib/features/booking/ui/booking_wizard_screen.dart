import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/booking_wizard_controller.dart';
import 'steps/service_selection_step.dart';
import 'steps/stylist_selection_step.dart';
import 'steps/datetime_selection_step.dart';
import 'steps/additional_info_step.dart';
import 'booking_confirmation_screen.dart';

class BookingWizardScreen extends ConsumerWidget {
  const BookingWizardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingWizardProvider);
    final controller = ref.read(bookingWizardProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment - Step ${state.step + 1} of 4'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress indicator
          LinearProgressIndicator(
            value: (state.step + 1) / 4,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Step content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _buildStepContent(context, ref, state),
            ),
          ),
          
          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!state.isFirstStep)
                  ElevatedButton(
                    onPressed: controller.previous,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[600],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Previous'),
                  )
                else
                  const SizedBox.shrink(),
                
                if (!state.isLastStep)
                  ElevatedButton(
                    onPressed: state.canProceed ? controller.next : null,
                    child: const Text('Next'),
                  )
                else
                  ElevatedButton(
                    onPressed: state.canProceed ? () => _proceedToConfirmation(context, ref) : null,
                    child: const Text('Review & Book'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, WidgetRef ref, state) {
    switch (state.step) {
      case 0:
        return const ServiceSelectionStep();
      case 1:
        return const StylistSelectionStep();
      case 2:
        return const DateTimeSelectionStep();
      case 3:
        return const AdditionalInfoStep();
      default:
        return const Center(child: Text('Invalid step'));
    }
  }

  void _proceedToConfirmation(BuildContext context, WidgetRef ref) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const BookingConfirmationScreen(),
      ),
    );
  }
}