import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SetupVehicleScreen extends StatefulWidget {
  @override
  _SetupVehicleScreenState createState() => _SetupVehicleScreenState();
}

class _SetupVehicleScreenState extends State<SetupVehicleScreen> {
  // 1. असली भारतीय गाड़ियों का डेटाबेस (इसे बाद में Backend API से जोड़ा जा सकता है)
  final Map<String, List<String>> _vehicleDatabase = {
    "Maruti Suzuki": ["Swift", "Baleno", "Brezza", "WagonR", "Alto", "Ertiga"],
    "Tata Motors": ["Nexon", "Punch", "Harrier", "Tiago", "Safari", "Altroz"],
    "Mahindra": ["Scorpio", "Thar", "XUV700", "Bolero", "XUV300"],
    "Hyundai": ["Creta", "i20", "Venue", "Verna", "Grand i10"],
    "Honda": ["City", "Amaze", "Elevate"],
    "Toyota": ["Fortuner", "Innova Crysta", "Glanza", "Hyryder"],
    "Royal Enfield (2W)": ["Classic 350", "Hunter 350", "Meteor", "Himalayan"],
    "TVS (2W)": ["Apache RTR", "Jupiter", "Raider", "Ntorq"]
  };

  final List<String> _fuelTypes = ["Petrol", "Diesel", "CNG", "EV"];

  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedFuel;

  void _saveAndContinue() {
    if (_selectedBrand == null || _selectedModel == null || _selectedFuel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("कृपया गाड़ी की सभी डिटेल्स चुनें!"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }
    
    // डिटेल्स सेव हो गईं, अब डैशबोर्ड पर भेजें
    Navigator.pushReplacementNamed(context, '/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), // MechaniQ Theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 40),
              Text(
                "SETUP VEHICLE",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent,
                ),
              ),
              SizedBox(height: 16),
              Text(
                "MechaniQ needs your vehicle details to select the correct OBD2 protocols and AI models.",
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14),
              ),
              SizedBox(height: 40),

              // BRAND DROPDOWN
              _buildDropdown(
                hint: "Select Brand",
                value: _selectedBrand,
                items: _vehicleDatabase.keys.toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBrand = value as String;
                    _selectedModel = null; // जब कंपनी बदले, तो मॉडल रीसेट हो जाए
                  });
                },
              ),
              SizedBox(height: 20),

              // MODEL DROPDOWN (यह तभी काम करेगा जब Brand चुना गया हो)
              _buildDropdown(
                hint: "Select Model",
                value: _selectedModel,
                items: _selectedBrand != null ? _vehicleDatabase[_selectedBrand]! : [],
                onChanged: _selectedBrand == null
                    ? null
                    : (value) {
                        setState(() {
                          _selectedModel = value as String;
                        });
                      },
              ),
              SizedBox(height: 20),

              // FUEL TYPE DROPDOWN
              _buildDropdown(
                hint: "Fuel Type",
                value: _selectedFuel,
                items: _fuelTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedFuel = value as String;
                  });
                },
              ),
              
              Spacer(),
              
              // SAVE BUTTON
              ElevatedButton(
                onPressed: _saveAndContinue,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.cyanAccent),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  "SAVE & CONTINUE",
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.cyanAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // कस्टम ड्रॉपडाउन बनाने का फंक्शन ताकि कोड साफ रहे
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required void Function(Object?)? onChanged,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white24),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint, style: GoogleFonts.spaceGrotesk(color: Colors.white54)),
          dropdownColor: Color(0xFF161B22),
          icon: Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
          isExpanded: true,
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
