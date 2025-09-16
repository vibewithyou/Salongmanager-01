class BookingWizardState {
  final int step;
  final List<int> serviceIds;
  final int? stylistId;
  final DateTime? startAt;
  final String notes;
  final List<String> imagePaths; // TODO: file picker integration

  const BookingWizardState({
    this.step = 0,
    this.serviceIds = const [],
    this.stylistId,
    this.startAt,
    this.notes = '',
    this.imagePaths = const [],
  });

  BookingWizardState copyWith({
    int? step,
    List<int>? serviceIds,
    int? stylistId,
    DateTime? startAt,
    String? notes,
    List<String>? imagePaths,
  }) {
    return BookingWizardState(
      step: step ?? this.step,
      serviceIds: serviceIds ?? this.serviceIds,
      stylistId: stylistId ?? this.stylistId,
      startAt: startAt ?? this.startAt,
      notes: notes ?? this.notes,
      imagePaths: imagePaths ?? this.imagePaths,
    );
  }

  bool get canProceed {
    switch (step) {
      case 0:
        return serviceIds.isNotEmpty;
      case 1:
        return true; // stylist selection is optional
      case 2:
        return startAt != null;
      case 3:
        return true; // additional info is optional
      default:
        return false;
    }
  }

  bool get isLastStep => step >= 3;
  bool get isFirstStep => step <= 0;
}