import 'cart_item.dart';

class Cart {
  List<CartItem> items = [];

  double get totalPrice {
    double total = 0;
    for (var item in items) {
      total += item.price;
    }
    return total;
  }

  int get totalCount {
    int count = 0;
    for (var item in items) {
      count += item.quantity;
    }
    return count;
  }
}
