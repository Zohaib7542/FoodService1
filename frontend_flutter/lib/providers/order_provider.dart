import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../constants/urls.dart';
import 'auth_provider.dart';

class OrderProvider with ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> createOrder(Order order, AuthProvider authProvider) async {
    if (authProvider.currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppUrls.orderCreateUrl),
        headers: {
          'Content-Type': 'application/json',
          'access_token': authProvider.token,
        },
        body: json.encode({
          // Add necessary fields according to backend expectation
           'name': order.name,
           'address': order.address,
           'addressLatLng': order.addressLatLng?.toJson() ?? {'lat': '0', 'lng': '0'},
           'paymentId': order.paymentId,
           'totalPrice': order.totalPrice,
           'items': order.items.map((item) => {
             'food': item.food.toJson(),
             'price': item.price,
             'quantity': item.quantity,
           }).toList(),
           'status': order.status,
           'createdAt': order.createdAt,
        }),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = 'Failed to create order';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Other methods (pay order, track order, etc.)
}
