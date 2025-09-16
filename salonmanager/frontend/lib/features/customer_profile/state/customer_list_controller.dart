import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/customer_repository.dart';
import '../models/customer.dart';

class CustomerListState {
  final bool loading;
  final List<Customer> customers;
  final String search;
  final int? nextPage;

  const CustomerListState({
    this.loading = false,
    this.customers = const [],
    this.search = '',
    this.nextPage = 1,
  });

  CustomerListState copyWith({
    bool? loading,
    List<Customer>? customers,
    String? search,
    int? nextPage,
  }) =>
      CustomerListState(
        loading: loading ?? this.loading,
        customers: customers ?? this.customers,
        search: search ?? this.search,
        nextPage: nextPage,
      );
}

final customerRepositoryProvider = Provider<CustomerRepository>((ref) => CustomerRepository());

final customerListControllerProvider = StateNotifierProvider<CustomerListController, CustomerListState>(
    (ref) => CustomerListController(ref.watch(customerRepositoryProvider)));

class CustomerListController extends StateNotifier<CustomerListState> {
  final CustomerRepository _repo;

  CustomerListController(this._repo) : super(const CustomerListState()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(loading: true, customers: [], nextPage: 1);
    await loadMore();
  }

  Future<void> loadMore() async {
    if (state.nextPage == null) return;
    final (items, next) = await _repo.fetchCustomers(
      search: state.search,
      page: state.nextPage!,
    );
    state = state.copyWith(
      loading: false,
      customers: [...state.customers, ...items],
      nextPage: next,
    );
  }

  void setSearch(String s) {
    state = state.copyWith(search: s);
    refresh();
  }
}