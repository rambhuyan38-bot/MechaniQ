import 'package:flutter/material.dart';

class VehicleProvider extends ChangeNotifier {
  String _currentVehicle = "Tesla Model Y";
  String get currentVehicle => _currentVehicle;

  void updateVehicle(String newVehicle) {
    _currentVehicle = newVehicle;
    notifyListeners();
  }
}