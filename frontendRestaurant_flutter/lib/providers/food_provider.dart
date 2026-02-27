import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/food.dart';
import '../constants/urls.dart';
import 'auth_provider.dart';

class FoodProvider with ChangeNotifier {
  List<Food> _foods = [];
  bool _isLoading = false;
  String? _error;

  List<Food> get foods => _foods;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final AuthProvider authProvider;

  FoodProvider({required this.authProvider});

  Future<void> fetchFoodsForRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('${AppUrls.foodsByRestaurantUrl}$restaurantId'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _foods = data.map((json) => Food.fromJson(json)).toList();
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to load foods';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> createFood({
    required String name,
    required double price,
    required String imageUrl,
    required String cookTime,
    required List<String> tags,
    required List<String> origins,
  }) async {
    if (!authProvider.isAuthenticated) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse(AppUrls.foodCreateUrl),
        headers: {
          'Content-Type': 'application/json',
          'access_token': authProvider.token,
        },
        body: json.encode({
          'name': name,
          'price': price,
          'imageUrl': imageUrl,
          'cookTime': cookTime,
          'tags': tags,
          'origins': origins,
          'favorite': false,
          'stars': 5,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newFood = Food.fromJson(json.decode(response.body));
        _foods.add(newFood);
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to create food';
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
    _foods = [];
    _error = null;
    notifyListeners();
  }
}
