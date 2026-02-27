import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../constants/urls.dart';
import 'auth_provider.dart';

class RestaurantProvider with ChangeNotifier {
  Restaurant? _myRestaurant;
  bool _isLoading = false;
  String? _error;

  Restaurant? get myRestaurant => _myRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AuthProvider authProvider;

  RestaurantProvider({required this.authProvider});

  Future<void> fetchMyRestaurant() async {
    if (!authProvider.isAuthenticated) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse(AppUrls.restaurantMineUrl),
        headers: {
          'Content-Type': 'application/json',
          'access_token': authProvider.token,
        },
      );

      if (response.statusCode == 200) {
        _myRestaurant = Restaurant.fromJson(json.decode(response.body));
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to load restaurant profile';
        _myRestaurant = null;
      }
    } catch (e) {
      _error = e.toString();
      _myRestaurant = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createRestaurant({
    required String name,
    required String address,
    required String imageUrl,
  }) async {
    if (!authProvider.isAuthenticated) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppUrls.restaurantCreateUrl),
        headers: {
          'Content-Type': 'application/json',
          'access_token': authProvider.token,
        },
        body: json.encode({
          'name': name,
          'address': address,
          'imageUrl': imageUrl,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _myRestaurant = Restaurant.fromJson(json.decode(response.body));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to create restaurant';
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

  void clear() {
    _myRestaurant = null;
    _error = null;
    notifyListeners();
  }
}
