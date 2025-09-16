import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/pos_repository.dart';
import '../models/cart_item.dart';
import 'pos_state.dart';
import '../models/invoice.dart';

final posRepositoryProvider = Provider<PosRepository>((_) => PosRepository());
final posControllerProvider = StateNotifierProvider<PosController, PosState>(
    (ref) => PosController(ref.read(posRepositoryProvider)));

class PosController extends StateNotifier<PosState> {
  final PosRepository _repo;

  PosController(this._repo) : super(const PosState());

  void addItem(CartItem item) {
    final next = [...state.cart, item];
    _recalc(next);
  }

  void removeItem(int index) {
    final next = [...state.cart]..removeAt(index);
    _recalc(next);
  }

  void clear() => state = const PosState();

  void _recalc(List<CartItem> list) {
    double net = 0, tax = 0, gross = 0;
    
    for (final item in list) {
      final q = item.qty.toDouble();
      double lineNet = q * item.unitNet;
      
      if (item.discount != null) {
        final d = item.discount!;
        if (d is Map && d.containsKey('percent')) {
          lineNet -= lineNet * (d['percent'] / 100.0);
        } else {
          lineNet -= (d as num).toDouble();
        }
      }
      
      lineNet = lineNet < 0 ? 0 : double.parse(lineNet.toStringAsFixed(2));
      final lineTax = double.parse((lineNet * item.taxRate / 100.0).toStringAsFixed(2));
      net += lineNet;
      tax += lineTax;
      gross += lineNet + lineTax;
    }
    
    state = state.copyWith(
      cart: list,
      totalNet: double.parse(net.toStringAsFixed(2)),
      totalTax: double.parse(tax.toStringAsFixed(2)),
      totalGross: double.parse(gross.toStringAsFixed(2)),
    );
  }

  Future<Invoice> checkout({int? customerId, required String method}) async {
    state = state.copyWith(paying: true);
    try {
      final invoice = await _repo.createInvoice(
        customerId: customerId,
        items: state.cart,
      );
      await _repo.payInvoice(invoice.id, method: method, amount: state.totalGross);
      clear();
      return invoice;
    } finally {
      state = state.copyWith(paying: false);
    }
  }

  Future<void> refund({
    required int invoiceId,
    required double amount,
    String? reason,
  }) async {
    await _repo.refundInvoice(invoiceId, amount: amount, reason: reason);
  }
}