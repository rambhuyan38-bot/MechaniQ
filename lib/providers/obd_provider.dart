import 'package:flutter/material.dart';

class ObdProvider extends ChangeNotifier {
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  void toggleConnection() {
    _isConnected = !_isConnected;
    notifyListeners();
  }
}