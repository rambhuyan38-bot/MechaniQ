import 'package:flutter/material.dart';
import '../models/vehicle.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String selectedType = 'Car';
  String selectedBrand = 'Tata';
  String selectedModel = 'Nexon';
  int selectedYear = 2022;
  String selectedFuel = 'EV';

  final List<String> types = ['Two-Wheeler', 'Car', 'EV'];
  final List<String> brands = ['Tata', 'Mahindra', 'Honda', 'Suzuki', 'Ather', 'Ola'];
  final List<String> models = ['Nexon', 'Punch', 'XUV700', 'Thar', 'City', 'Activa', '450X'];
  final List<String> fuelTypes = ['Petrol', 'Diesel', 'EV'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configure Vehicle Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Let\'s build your vehicle OBD profile',
                style: TextStyle(color: Color(0xFF00F2FE), fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildSelectorCard('Vehicle Type', types, selectedType, (val) {
                setState(() => selectedType = val!);
              }),
              _buildSelectorCard('Brand Name', brands, selectedBrand, (val) {
                setState(() => selectedBrand = val!);
              }),
              _buildSelectorCard('Model', models, selectedModel, (val) {
                setState(() => selectedModel = val!);
              }),
              _buildSelectorCard('Fuel Type', fuelTypes, selectedFuel, (val) {
                setState(() => selectedFuel = val!);
              }),
              const SizedBox(height: 24),
              Card(
                color: const Color(0xFF1F2833),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: Color(0xFF00FF87), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Model Year', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      DropdownButton<int>(
                        value: selectedYear,
                        dropdownColor: const Color(0xFF1F2833),
                        items: [2018, 2019, 2020, 2021, 2022, 2023]
                            .map((y) => DropdownMenuItem(value: y, child: Text(y.toString())))
                            .toList(),
                        onChanged: (val) {
                          setState(() => selectedYear = val!);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  final vehicle = Vehicle(
                    type: selectedType,
                    brand: selectedBrand,
                    model: selectedModel,
                    year: selectedYear,
                    fuelType: selectedFuel,
                  );
                  Navigator.of(context).pushReplacementNamed('/home', arguments: vehicle);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF87),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 8,
                ),
                child: const Text('CONFIRM PROFILE & CONTINUE', style: TextStyle(fontWeight: FontWeight.bold)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectorCard(String title, List<String> options, String current, ValueChanged<String?> change) {
    return Card(
      color: const Color(0xFF1F2833),
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              value: current,
              dropdownColor: const Color(0xFF1F2833),
              underline: const SizedBox(),
              items: options.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
              onChanged: change,
            )
          ],
        ),
      ),
    );
  }
}