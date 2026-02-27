import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String get token => _currentUser?.token ?? '';

  Future<void> checkLoginStatus() async {
    _currentUser = await AuthService.getUserFromLocal();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.login(email, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String address,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentUser = await AuthService.register(
        name: name,
        email: email,
        password: password,
        address: address,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> syncPoints() async {
    if (_currentUser == null) return;
    try {
      final points = await AuthService.fetchUserPoints(_currentUser!.email);
      _currentUser!.loyaltyPoints = points;
      await AuthService.saveUserToLocal(_currentUser!);
      notifyListeners();
    } catch (e) {
      // Ignore err on background sync
      debugPrint('Failed to sync points: $e');
    }
  }

  Future<void> redeemPoints(int points) async {
    if (_currentUser == null) return;
    try {
      final newBalance = await AuthService.redeemPoints(_currentUser!.email, points);
      _currentUser!.loyaltyPoints = newBalance;
      await AuthService.saveUserToLocal(_currentUser!);
      notifyListeners();
    } catch (e) {
      throw Exception('Could not redeem points: $e');
    }
  }

  Future<void> logout() async {
    await AuthService.logout();
    _currentUser = null;
    notifyListeners();
  }
}
