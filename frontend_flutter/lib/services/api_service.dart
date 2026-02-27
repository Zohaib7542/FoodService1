import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/urls.dart';
import '../models/food.dart';
import '../models/tag.dart';

class ApiService {
  static Future<List<Food>> getAllFoods() async {
    final response = await http.get(Uri.parse(AppUrls.foodsUrl));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Food>.from(l.map((model) => Food.fromJson(model)));
    } else {
      throw Exception('Failed to load foods');
    }
  }

  static Future<List<Food>> getFoodsBySearchTerm(String searchTerm) async {
    final response = await http.get(Uri.parse('${AppUrls.foodsBySearchUrl}$searchTerm'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Food>.from(l.map((model) => Food.fromJson(model)));
    } else {
      throw Exception('Failed to load search results');
    }
  }

  static Future<List<Tag>> getAllTags() async {
    final response = await http.get(Uri.parse(AppUrls.foodsTagsUrl));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Tag>.from(l.map((model) => Tag.fromJson(model)));
    } else {
      throw Exception('Failed to load tags');
    }
  }

  static Future<List<Food>> getFoodsByTag(String tag) async {
    if (tag == 'All') return getAllFoods();
    final response = await http.get(Uri.parse('${AppUrls.foodsByTagUrl}$tag'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Food>.from(l.map((model) => Food.fromJson(model)));
    } else {
      throw Exception('Failed to load foods by tag');
    }
  }

  static Future<Food> getFoodById(String id) async {
    final response = await http.get(Uri.parse('${AppUrls.foodByIdUrl}$id'));
    if (response.statusCode == 200) {
      return Food.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load food');
    }
  }

  static Future<List<Food>> getFoodsByRestaurant(String restaurantId) async {
    final response = await http.get(Uri.parse('${AppUrls.foodsByRestaurantUrl}$restaurantId'));
    if (response.statusCode == 200) {
      Iterable l = json.decode(response.body);
      return List<Food>.from(l.map((model) => Food.fromJson(model)));
    } else {
      throw Exception('Failed to load restaurant foods');
    }
  }
}
