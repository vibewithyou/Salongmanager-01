import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../common/layout/page_scaffold.dart';
import '../../../common/ui/sm_button.dart';
import '../../../common/ui/sm_card.dart';
import '../../../common/ui/sm_input.dart';
import '../../../common/ui/sm_select.dart';
import '../../../common/ui/sm_date_time_field.dart';
import '../../../common/ui/sm_toast.dart';
import '../../../core/theme/tokens.dart';

/// Booking wizard state
class BookingWizardState {
  final int currentStep;
  final String? selectedService;
  final String? selectedStylist;
  final DateTime? selectedDateTime;
  final String? customerName;
  final String? customerEmail;
  final String? customerPhone;
  final String? notes;
  final List<String> uploadedImages;
  final bool isLoading;
  final String? error;

  const BookingWizardState({
    this.currentStep = 0,
    this.selectedService,
    this.selectedStylist,
    this.selectedDateTime,
    this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.notes,
    this.uploadedImages = const [],
    this.isLoading = false,
    this.error,
  });

  BookingWizardState copyWith({
    int? currentStep,
    String? selectedService,
    String? selectedStylist,
    DateTime? selectedDateTime,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    String? notes,
    List<String>? uploadedImages,
    bool? isLoading,
    String? error,
  }) {
    return BookingWizardState(
      currentStep: currentStep ?? this.currentStep,
      selectedService: selectedService ?? this.selectedService,
      selectedStylist: selectedStylist ?? this.selectedStylist,
      selectedDateTime: selectedDateTime ?? this.selectedDateTime,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      notes: notes ?? this.notes,
      uploadedImages: uploadedImages ?? this.uploadedImages,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  bool get canProceed {
    switch (currentStep) {
      case 0:
        return selectedService != null;
      case 1:
        return selectedStylist != null;
      case 2:
        return selectedDateTime != null;
      case 3:
        return customerName != null && customerEmail != null;
      default:
        return false;
    }
  }
}

/// Booking wizard controller
final bookingWizardProvider = StateNotifierProvider<BookingWizardController, BookingWizardState>((ref) {
  return BookingWizardController(ref);
});

class BookingWizardController extends StateNotifier<BookingWizardState> {
  final Ref _ref;

  BookingWizardController(this._ref) : super(const BookingWizardState());

  void nextStep() {
    if (state.canProceed && state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void selectService(String service) {
    state = state.copyWith(selectedService: service);
  }

  void selectStylist(String stylist) {
    state = state.copyWith(selectedStylist: stylist);
  }

  void selectDateTime(DateTime dateTime) {
    state = state.copyWith(selectedDateTime: dateTime);
  }

  void updateCustomerName(String name) {
    state = state.copyWith(customerName: name);
  }

  void updateCustomerEmail(String email) {
    state = state.copyWith(customerEmail: email);
  }

  void updateCustomerPhone(String phone) {
    state = state.copyWith(customerPhone: phone);
  }

  void updateNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  Future<void> submitBooking() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Implement actual booking submission
      await Future.delayed(const Duration(seconds: 2));

      // Simulate success
      _ref.read(toastControllerProvider.notifier).showSuccess(
        'Buchung erfolgreich erstellt!',
        title: 'Termin bestätigt',
      );

      // Navigate to success page
      // TODO: Pass booking details to success page
      GoRouter.of(_ref.context).go('/bookings/success');
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Fehler beim Erstellen der Buchung: $e',
      );
      _ref.read(toastControllerProvider.notifier).showError(
        'Fehler beim Erstellen der Buchung',
        title: 'Buchung fehlgeschlagen',
      );
    }
  }
}

/// Main booking wizard page
class BookingWizardPage extends ConsumerWidget {
  const BookingWizardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingWizardProvider);
    final controller = ref.read(bookingWizardProvider.notifier);

    return PageScaffold(
      title: 'Termin buchen',
      body: Column(
        children: [
          _buildProgressIndicator(context, state.currentStep),
          Expanded(
            child: _buildStepContent(context, ref, state, controller),
          ),
          _buildNavigationButtons(context, ref, state, controller),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context, int currentStep) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Row(
        children: [
          for (int i = 0; i < 5; i++) ...[
            Expanded(
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  color: i <= currentStep ? cs.primary : cs.outline.withOpacity(0.3),
                  borderRadius: SMTokens.rSm,
                ),
              ),
            ),
            if (i < 4) const SizedBox(width: SMTokens.s2),
          ],
        ],
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    switch (state.currentStep) {
      case 0:
        return _buildServiceSelection(context, ref, state, controller);
      case 1:
        return _buildStylistSelection(context, ref, state, controller);
      case 2:
        return _buildDateTimeSelection(context, ref, state, controller);
      case 3:
        return _buildCustomerDetails(context, ref, state, controller);
      case 4:
        return _buildReview(context, ref, state, controller);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildServiceSelection(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    final services = [
      SMSelectOption(value: 'haircut', label: 'Haarschnitt', icon: Icons.content_cut),
      SMSelectOption(value: 'coloring', label: 'Coloration', icon: Icons.palette),
      SMSelectOption(value: 'styling', label: 'Styling', icon: Icons.brush),
      SMSelectOption(value: 'manicure', label: 'Maniküre', icon: Icons.self_improvement),
      SMSelectOption(value: 'pedicure', label: 'Pediküre', icon: Icons.self_improvement),
    ];

    return Padding(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wähle eine Leistung',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SMTokens.s2),
          Text(
            'Welche Leistung möchtest du buchen?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SMTokens.s6),
          ...services.map((service) => Padding(
            padding: const EdgeInsets.only(bottom: SMTokens.s3),
            child: SMCard(
              onTap: () => controller.selectService(service.value),
              color: state.selectedService == service.value
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
              child: Row(
                children: [
                  Icon(
                    service.icon,
                    color: state.selectedService == service.value
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: SMTokens.s3),
                  Expanded(
                    child: Text(
                      service.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: state.selectedService == service.value
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        fontWeight: state.selectedService == service.value
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (state.selectedService == service.value)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildStylistSelection(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    final stylists = [
      SMSelectOption(value: 'maria', label: 'Maria Schmidt', icon: Icons.person),
      SMSelectOption(value: 'sarah', label: 'Sarah Weber', icon: Icons.person),
      SMSelectOption(value: 'tom', label: 'Tom Müller', icon: Icons.person),
    ];

    return Padding(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wähle einen Stylist',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SMTokens.s2),
          Text(
            'Wer soll deine Leistung durchführen?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SMTokens.s6),
          ...stylists.map((stylist) => Padding(
            padding: const EdgeInsets.only(bottom: SMTokens.s3),
            child: SMCard(
              onTap: () => controller.selectStylist(stylist.value),
              color: state.selectedStylist == stylist.value
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : null,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: state.selectedStylist == stylist.value
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceVariant,
                    child: Icon(
                      stylist.icon,
                      color: state.selectedStylist == stylist.value
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: SMTokens.s3),
                  Expanded(
                    child: Text(
                      stylist.label,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: state.selectedStylist == stylist.value
                            ? Theme.of(context).colorScheme.primary
                            : null,
                        fontWeight: state.selectedStylist == stylist.value
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                  if (state.selectedStylist == stylist.value)
                    Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildDateTimeSelection(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    return Padding(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wähle Datum und Uhrzeit',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SMTokens.s2),
          Text(
            'Wann soll dein Termin stattfinden?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SMTokens.s6),
          SMDateTimeField(
            label: 'Datum und Uhrzeit',
            value: state.selectedDateTime,
            onChanged: controller.selectDateTime,
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 90)),
          ),
          const SizedBox(height: SMTokens.s4),
          if (state.selectedDateTime != null) ...[
            SMCard(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: SMTokens.s3),
                  Expanded(
                    child: Text(
                      'Gewählter Termin: ${DateFormat('dd.MM.yyyy HH:mm').format(state.selectedDateTime!)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomerDetails(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    return Padding(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deine Kontaktdaten',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SMTokens.s2),
          Text(
            'Bitte gib deine Kontaktdaten ein:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SMTokens.s6),
          SMInput(
            label: 'Name',
            value: state.customerName,
            onChanged: controller.updateCustomerName,
            required: true,
          ),
          const SizedBox(height: SMTokens.s4),
          SMInput(
            label: 'E-Mail',
            value: state.customerEmail,
            onChanged: controller.updateCustomerEmail,
            keyboardType: TextInputType.emailAddress,
            required: true,
          ),
          const SizedBox(height: SMTokens.s4),
          SMInput(
            label: 'Telefon (optional)',
            value: state.customerPhone,
            onChanged: controller.updateCustomerPhone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: SMTokens.s4),
          SMTextArea(
            label: 'Notizen (optional)',
            value: state.notes,
            onChanged: controller.updateNotes,
            hint: 'Besondere Wünsche oder Anmerkungen...',
          ),
        ],
      ),
    );
  }

  Widget _buildReview(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    return Padding(
      padding: const EdgeInsets.all(SMTokens.s4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buchung bestätigen',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: SMTokens.s2),
          Text(
            'Bitte überprüfe deine Buchung:',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: SMTokens.s6),
          SMCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buchungsdetails',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: SMTokens.s4),
                _buildReviewItem('Leistung', state.selectedService ?? 'Nicht ausgewählt'),
                _buildReviewItem('Stylist', state.selectedStylist ?? 'Nicht ausgewählt'),
                _buildReviewItem('Datum & Zeit', state.selectedDateTime != null 
                    ? DateFormat('dd.MM.yyyy HH:mm').format(state.selectedDateTime!)
                    : 'Nicht ausgewählt'),
                _buildReviewItem('Name', state.customerName ?? 'Nicht angegeben'),
                _buildReviewItem('E-Mail', state.customerEmail ?? 'Nicht angegeben'),
                if (state.customerPhone != null)
                  _buildReviewItem('Telefon', state.customerPhone!),
                if (state.notes != null)
                  _buildReviewItem('Notizen', state.notes!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SMTokens.s2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons(BuildContext context, WidgetRef ref, BookingWizardState state, BookingWizardController controller) {
    return Container(
      padding: const EdgeInsets.all(SMTokens.s4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
      ),
      child: Row(
        children: [
          if (state.currentStep > 0)
            Expanded(
              child: SMSecondaryButton(
                onPressed: controller.previousStep,
                child: const Text('Zurück'),
              ),
            ),
          if (state.currentStep > 0) const SizedBox(width: SMTokens.s3),
          Expanded(
            child: SMPrimaryButton(
              onPressed: state.canProceed && !state.isLoading
                  ? (state.currentStep == 4 ? controller.submitBooking : controller.nextStep)
                  : null,
              isLoading: state.isLoading,
              child: Text(state.currentStep == 4 ? 'Buchung erstellen' : 'Weiter'),
            ),
          ),
        ],
      ),
    );
  }
}
