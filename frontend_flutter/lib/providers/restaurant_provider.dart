import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/restaurant.dart';
import '../constants/urls.dart';

class RestaurantProvider with ChangeNotifier {
  List<Restaurant> _restaurants = [];
  bool _isLoading = false;
  String? _error;

  List<Restaurant> get restaurants => _restaurants;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchRestaurants() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(AppUrls.restaurantsUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _restaurants = data.map((json) => Restaurant.fromJson(json)).toList();
      } else {
        _error = json.decode(response.body)['message'] ?? 'Failed to load restaurants';
      }
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Restaurant? getRestaurantById(String id) {
    try {
      return _restaurants.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }
}
