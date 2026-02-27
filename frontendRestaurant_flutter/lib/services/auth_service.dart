import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/urls.dart';
import '../models/user.dart';

class AuthService {
  static const String _userKey = 'user_info';

  static Future<User?> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.userLoginUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final user = User.fromJson(userData);
        if (!user.isRestaurantOwner) {
          throw Exception('You are not registered as a restaurant owner. Please use the customer app.');
        }
        await saveUserToLocal(user);
        return user;
      } else {
        throw Exception(json.decode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<User?> register({
    required String name,
    required String email,
    required String password,
    required String address,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(AppUrls.userRegisterUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'address': address,
          'isRestaurantOwner': true,
        }),
      );

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        final user = User.fromJson(userData);
        await saveUserToLocal(user);
        return user;
      } else {
         throw Exception(json.decode(response.body)['message'] ?? 'Registration failed');
      }
    } catch (e) {
       throw Exception(e.toString());
    }
  }

  static Future<void> saveUserToLocal(User user) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_userKey, json.encode(user.toJson()));
  }

  static Future<User?> getUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      return User.fromJson(json.decode(userStr));
    }
    return null;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
