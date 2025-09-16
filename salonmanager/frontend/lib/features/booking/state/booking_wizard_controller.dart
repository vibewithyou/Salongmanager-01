import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'booking_wizard_state.dart';

final bookingWizardProvider = StateNotifierProvider<BookingWizardController, BookingWizardState>(
  (ref) => BookingWizardController(),
);

class BookingWizardController extends StateNotifier<BookingWizardState> {
  BookingWizardController() : super(const BookingWizardState());

  void next() {
    if (state.canProceed && !state.isLastStep) {
      state = state.copyWith(step: state.step + 1);
    }
  }

  void previous() {
    if (!state.isFirstStep) {
      state = state.copyWith(step: state.step - 1);
    }
  }

  void setServices(List<int> ids) {
    state = state.copyWith(serviceIds: ids);
  }

  void setStylist(int? id) {
    state = state.copyWith(stylistId: id);
  }

  void setStartAt(DateTime dateTime) {
    state = state.copyWith(startAt: dateTime);
  }

  void setNotes(String notes) {
    state = state.copyWith(notes: notes);
  }

  void addImage(String path) {
    if (state.imagePaths.length < 5) {
      state = state.copyWith(
        imagePaths: [...state.imagePaths, path],
      );
    }
  }

  void removeImage(int index) {
    if (index >= 0 && index < state.imagePaths.length) {
      final newPaths = List<String>.from(state.imagePaths);
      newPaths.removeAt(index);
      state = state.copyWith(imagePaths: newPaths);
    }
  }

  void reset() {
    state = const BookingWizardState();
  }
}