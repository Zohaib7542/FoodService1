import 'food.dart';

class CartItem {
  Food food;
  int quantity;
  double price;

  CartItem({
    required this.food,
    this.quantity = 1,
  }) : price = food.price;

  // Recalculate price when quantity changes
  void updateQuantity(int newQuantity) {
    quantity = newQuantity;
    price = food.price * quantity;
  }
}
