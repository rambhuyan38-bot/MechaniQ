import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';

class VehicleProvider with ChangeNotifier {
  final List<Vehicle> _vehicles = [
    Vehicle(
      id: '1',
      make: 'Porsche',
      model: '911 Carrera S',
      year: '2022',
      vin: 'WP0AB2A90NS22109',
      engineType: '3.0L Twin-Turbo Flat-6',
      status: 'Optimal',
    ),
    Vehicle(
      id: '2',
      make: 'Ford',
      model: 'Mustang GT',
      year: '2020',
      vin: '1FA6P8CF3LF10922',
      engineType: '5.0L Coyote V8',
      status: 'Requires Scan',
    ),
  ];

  int _selectedVehicleIndex = 0;

  List<Vehicle> get vehicles => List.unmodifiable(_vehicles);
  Vehicle get selectedVehicle => _vehicles[_selectedVehicleIndex];

  void selectVehicle(int index) {
    if (index >= 0 && index < _vehicles.length) {
      _selectedVehicleIndex = index;
      notifyListeners();
    }
  }

  void addVehicle(Vehicle vehicle) {
    _vehicles.add(vehicle);
    _selectedVehicleIndex = _vehicles.length - 1;
    notifyListeners();
  }

  void updateVehicleStatus(String vehicleId, String status) {
    final index = _vehicles.indexWhere((v) => v.id == vehicleId);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(status: status);
      notifyListeners();
    }
  }
}