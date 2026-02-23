import 'package:flutter/material.dart';
import '../models/cart.dart';
import '../models/cart_item.dart';
import '../models/food.dart';

class CartProvider with ChangeNotifier {
  final Cart _cart = Cart();

  Cart get cart => _cart;

  void addToCart(Food food) {
    try {
      // Check if already in cart
      var item = _cart.items.firstWhere((item) => item.food.id == food.id);
      item.updateQuantity(item.quantity + 1);
    } catch (e) {
      // Not in cart, add new
      _cart.items.add(CartItem(food: food));
    }
    notifyListeners();
  }

  void removeFromCart(String foodId) {
    _cart.items.removeWhere((item) => item.food.id == foodId);
    notifyListeners();
  }

  void changeQuantity(String foodId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(foodId);
      return;
    }
    try {
      var item = _cart.items.firstWhere((item) => item.food.id == foodId);
      item.updateQuantity(quantity);
      notifyListeners();
    } catch (e) {
      // Item not found
    }
  }

  void clearCart() {
    _cart.items.clear();
    notifyListeners();
  }
}
