import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  String? selectedVehicleType;
  String? selectedBrand;
  String? selectedFuel;

  // डमी ऑप्शंस (बाद में इसे SQLite डेटाबेस से जोड़ेंगे)
  final List<String> vehicleTypes = ['2-Wheeler (BS6)', '4-Wheeler (Car)', 'Electric Vehicle (EV)'];
  final List<String> brands = ['Honda', 'Tata', 'Mahindra', 'Maruti Suzuki', 'Royal Enfield', 'Ather'];
  final List<String> fuelTypes = ['Petrol', 'Diesel', 'Electric'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'SETUP VEHICLE',
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryNeonBlue,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'MechaniQ needs your vehicle details to select the correct OBD2 protocols and AI models.',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 14,
                  color: Colors.white70,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),

              // Vehicle Type Dropdown
              _buildDropdown(
                hint: 'Select Vehicle Type',
                value: selectedVehicleType,
                items: vehicleTypes,
                onChanged: (val) => setState(() => selectedVehicleType = val as String?),
                icon: Icons.directions_car_outlined,
              ),
              const SizedBox(height: 20),

              // Brand Dropdown
              _buildDropdown(
                hint: 'Select Brand',
                value: selectedBrand,
                items: brands,
                onChanged: (val) => setState(() => selectedBrand = val as String?),
                icon: Icons.branding_watermark_outlined,
              ),
              const SizedBox(height: 20),

              // Fuel Type Dropdown
              _buildDropdown(
                hint: 'Select Fuel Type',
                value: selectedFuel,
                items: fuelTypes,
                onChanged: (val) => setState(() => selectedFuel = val as String?),
                icon: Icons.local_gas_station_outlined,
              ),

              const Spacer(),

              // Glowing Continue Button
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (selectedVehicleType != null && selectedBrand != null && selectedFuel != null)
                        ? AppColors.primaryNeonBlue.withOpacity(0.2)
                        : Colors.white10,
                    side: BorderSide(
                      color: (selectedVehicleType != null && selectedBrand != null && selectedFuel != null)
                          ? AppColors.primaryNeonBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () {
                    // जब तीनों सेलेक्ट हो जाएं तभी आगे बढ़ेगा
                    if (selectedVehicleType != null && selectedBrand != null && selectedFuel != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const MainShell()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select all details to continue.')),
                      );
                    }
                  },
                  child: Text(
                    'SAVE & CONTINUE',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: (selectedVehicleType != null && selectedBrand != null && selectedFuel != null)
                          ? AppColors.primaryNeonBlue
                          : Colors.white54,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // कस्टम डार्क-नियन ड्रॉपडाउन विजेट
  Widget _buildDropdown({
    required String hint,
    required String? value,
    required List<String> items,
    required Function(Object?) onChanged,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          dropdownColor: const Color(0xFF14243B),
          icon: const Icon(Icons.arrow_drop_down, color: AppColors.primaryNeonBlue),
          hint: Row(
            children: [
              Icon(icon, color: Colors.white54, size: 20),
              const SizedBox(width: 15),
              Text(hint, style: GoogleFonts.spaceGrotesk(color: Colors.white54)),
            ],
          ),
          value: value,
          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16),
          items: items.map((String item) {
            return DropdownMenuItem(
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
