import 'package:flutter/material.dart';
import '../models/food.dart';
import '../models/tag.dart';
import '../services/api_service.dart';

class FoodProvider with ChangeNotifier {
  List<Food> _foods = [];
  List<Tag> _tags = [];
  bool _isLoading = false;
  String? _error;

  List<Food> get foods => _foods;
  List<Tag> get tags => _tags;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAllFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foods = await ApiService.getAllFoods();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllTags() async {
    try {
      _tags = await ApiService.getAllTags();
      notifyListeners();
    } catch (e) {
      print('Error fetching tags: $e');
    }
  }

  Future<void> searchFoods(String searchTerm) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (searchTerm.isEmpty) {
        _foods = await ApiService.getAllFoods();
      } else {
        _foods = await ApiService.getFoodsBySearchTerm(searchTerm);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> filterByTag(String tag) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foods = await ApiService.getFoodsByTag(tag);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Food?> getFoodById(String id) async {
    try {
      // First try to find it locally
      try {
        return _foods.firstWhere((food) => food.id == id);
      } catch (e) {
        // Not found locally, fetch from api
        return await ApiService.getFoodById(id);
      }
    } catch (e) {
      print('Error fetching food by id: $e');
      return null;
    }
  }

  Future<void> fetchFoodsForRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foods = await ApiService.getFoodsByRestaurant(restaurantId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
