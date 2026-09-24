import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;

  Future<bool> login(String email, String password) async {
    // Mock Login Setup
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.isNotEmpty) {
      _isAuthenticated = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    notifyListeners();
  }
}