import '../models/cart_item.dart';

class PosState {
  final List<CartItem> cart;
  final double totalNet;
  final double totalTax;
  final double totalGross;
  final bool paying;

  const PosState({
    this.cart = const [],
    this.totalNet = 0,
    this.totalTax = 0,
    this.totalGross = 0,
    this.paying = false,
  });

  PosState copyWith({
    List<CartItem>? cart,
    double? totalNet,
    double? totalTax,
    double? totalGross,
    bool? paying,
  }) =>
      PosState(
        cart: cart ?? this.cart,
        totalNet: totalNet ?? this.totalNet,
        totalTax: totalTax ?? this.totalTax,
        totalGross: totalGross ?? this.totalGross,
        paying: paying ?? this.paying,
      );
}