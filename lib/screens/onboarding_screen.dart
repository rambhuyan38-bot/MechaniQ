import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:mechaniq/main.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? _selectedType;
  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedFuel;

  final List<String> _vehicleTypes = ['Electric Car', 'Gasoline Car', 'Hybrid Car', 'Motorcycle', 'Heavy Truck'];
  
  final Map<String, List<String>> _brands = {
    'Electric Car': ['Tesla', 'BYD', 'Porsche', 'Audi', 'Hyundai'],
    'Gasoline Car': ['BMW', 'Mercedes-Benz', 'Audi', 'Toyota', 'Honda'],
    'Hybrid Car': ['Toyota', 'Honda', 'Lexus', 'Hyundai', 'Ford'],
    'Motorcycle': ['Yamaha', 'Honda', 'Ducati', 'BMW Motorrad', 'Kawasaki'],
    'Heavy Truck': ['Volvo', 'Scania', 'Mercedes-Benz Trucks', 'MAN', 'Kenworth'],
  };

  final Map<String, List<String>> _models = {
    'Tesla': ['Model S', 'Model 3', 'Model X', 'Model Y', 'Cybertruck'],
    'BMW': ['M3', 'M4', 'X5', 'i8', '330i'],
    'Porsche': ['Taycan', '911 Carrera', 'Cayenne', 'Macan'],
    'Yamaha': ['YZF-R1', 'MT-09', 'Tenere 700', 'R6'],
    'Volvo': ['FH16', 'FMX', 'FM', 'FE'],
    'Toyota': ['Prius Prime', 'RAV4 Hybrid', 'Supra', 'Land Cruiser'],
  };

  final List<String> _years = ['2024', '2023', '2022', '2021', '2020', '2019', '2018', '2017', '2016'];
  final List<String> _fuelTypes = ['100% Electric', 'Octane / Gasoline', 'Diesel Fuel', 'Hybrid Synergy', 'Hydrogen Cell'];

  void _onSaveAndContinue() {
    if (_selectedType != null &&
        _selectedBrand != null &&
        _selectedModel != null &&
        _selectedYear != null &&
        _selectedFuel != null) {
      
      final String fullConfig = "$_selectedYear $_selectedBrand $_selectedModel ($_selectedFuel)";
      Provider.of<AppStateProvider>(context, listen: false).updateVehicle(fullConfig);
      
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1E1015),
          content: Text(
            'CRITICAL WARNING: Please define all vehicle specifications.',
            style: GoogleFonts.shareTechMono(color: const Color(0xFFFF5252)),
          ),
        ),
      );
    }
  }

  Widget _buildStepDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.shareTechMono(
            fontSize: 12,
            color: const Color(0xFF00E5FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF121420),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF1F2444), width: 1.5),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: const Color(0xFF121420),
              icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF00FFCC)),
              isExpanded: true,
              hint: Text(
                'SELECT $label',
                style: GoogleFonts.shareTechMono(color: Colors.white30, fontSize: 14),
              ),
              onChanged: onChanged,
              items: items.map<DropdownMenuItem<String>>((String val) {
                return DropdownMenuItem<String>(
                  value: val,
                  child: Row(
                    children: [
                      Icon(icon, color: const Color(0xFF00FFCC), size: 18),
                      const SizedBox(width: 12),
                      Text(
                        val,
                        style: GoogleFonts.shareTechMono(color: Colors.white, fontSize: 15),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> dynamicBrands = _selectedType != null ? (_brands[_selectedType] ?? []) : [];
    List<String> dynamicModels = _selectedBrand != null ? (_models[_selectedBrand] ?? ['Standard Generic']) : [];

    return Scaffold(
      body: Stack(
        children: [
          // Cyberpunk glowing layout background
          Positioned.fill(
            child: Container(
              color: const Color(0xFF0A0B10),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00FFCC).withOpacity(0.05),
                blurRadius: 100,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                // Top Progress indicator bar
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VEHICLE PROFILING',
                        style: GoogleFonts.orbitron(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Calibrate MechaniQ parameters for optimal vehicle system analysis.',
                        style: GoogleFonts.shareTechMono(
                          fontSize: 13,
                          color: Colors.white54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Linear neon divider
                      Container(
                        height: 2,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF00FFCC), Color(0xFF00E5FF), Colors.transparent],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Form Area
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    children: [
                      _buildStepDropdown(
                        label: 'Vehicle Type',
                        value: _selectedType,
                        items: _vehicleTypes,
                        icon: Icons.directions_car_filled_outlined,
                        onChanged: (val) {
                          setState(() {
                            _selectedType = val;
                            _selectedBrand = null;
                            _selectedModel = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildStepDropdown(
                        label: 'Manufacturer / Brand',
                        value: _selectedBrand,
                        items: dynamicBrands,
                        icon: Icons.precision_manufacturing_outlined,
                        onChanged: (val) {
                          setState(() {
                            _selectedBrand = val;
                            _selectedModel = null;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildStepDropdown(
                        label: 'Specific Model',
                        value: _selectedModel,
                        items: dynamicModels,
                        icon: Icons.model_training,
                        onChanged: (val) {
                          setState(() {
                            _selectedModel = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildStepDropdown(
                        label: 'Production Year',
                        value: _selectedYear,
                        items: _years,
                        icon: Icons.calendar_today_outlined,
                        onChanged: (val) {
                          setState(() {
                            _selectedYear = val;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      _buildStepDropdown(
                        label: 'Propulsion Fuel Type',
                        value: _selectedFuel,
                        items: _fuelTypes,
                        icon: Icons.ev_station_outlined,
                        onChanged: (val) {
                          setState(() {
                            _selectedFuel = val;
                          });
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
                
                // Save and Continue bottom actions
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF121420),
                    border: Border(top: BorderSide(color: Color(0xFF1F2444), width: 1.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedModel != null
                              ? 'READY TO PAIR PROTOCOLS FOR $_selectedModel'
                              : 'CONFIGURING TELEMETRY CHANNELS',
                          style: GoogleFonts.shareTechMono(
                            fontSize: 12,
                            color: const Color(0xFF00FFCC),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 50,
                        width: 160,
                        child: ElevatedButton(
                          onPressed: _onSaveAndContinue,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'CONTINUE',
                                style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.arrow_forward_ios, size: 14),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}