import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customer_repository.dart';
import '../models/customer.dart';
import '../models/customer_profile.dart';
import '../models/customer_note.dart';
import '../models/loyalty.dart';

class CustomerDetailState {
  final bool loading;
  final Customer? customer;
  final CustomerProfile? profile;
  final List<CustomerNote> notes;
  final LoyaltyCard? card;
  final List<LoyaltyTx> txs;

  const CustomerDetailState({
    this.loading = false,
    this.customer,
    this.profile,
    this.notes = const [],
    this.card,
    this.txs = const [],
  });

  CustomerDetailState copyWith({
    bool? loading,
    Customer? customer,
    CustomerProfile? profile,
    List<CustomerNote>? notes,
    LoyaltyCard? card,
    List<LoyaltyTx>? txs,
  }) =>
      CustomerDetailState(
        loading: loading ?? this.loading,
        customer: customer ?? this.customer,
        profile: profile ?? this.profile,
        notes: notes ?? this.notes,
        card: card ?? this.card,
        txs: txs ?? this.txs,
      );
}

final customerDetailControllerProvider = StateNotifierProvider.family<CustomerDetailController, CustomerDetailState, int>(
    (ref, id) {
  return CustomerDetailController(ref.watch(customerRepositoryProvider), id);
});

class CustomerDetailController extends StateNotifier<CustomerDetailState> {
  final CustomerRepository _repo;
  final int id;

  CustomerDetailController(this._repo, this.id) : super(const CustomerDetailState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true);
    final (c, p) = await _repo.fetchCustomer(id);
    final notes = await _repo.fetchNotes(id);
    final (card, txs) = await _repo.fetchLoyalty(id);
    state = state.copyWith(
      loading: false,
      customer: c,
      profile: p,
      notes: notes,
      card: card,
      txs: txs,
    );
  }

  Future<void> addNote(String note) async {
    final n = await _repo.addNote(customerId: id, note: note);
    state = state.copyWith(notes: [n, ...state.notes]);
  }

  Future<void> adjustPoints(int delta, {String? reason}) async {
    final card = await _repo.adjustLoyalty(id, delta, reason: reason);
    await refresh(); // reload txs
  }
}