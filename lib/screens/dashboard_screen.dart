import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // डमी डेटा (बाद में इसे असली OBD डेटा से बदलेंगे)
  bool isConnected = false;
  int healthScore = 95;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'MECHANIQ',
          style: GoogleFonts.orbitron(
            color: AppColors.primaryNeonBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          // ब्लूटूथ कनेक्शन स्टेटस आइकन
          IconButton(
            icon: Icon(
              isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
              color: isConnected ? Colors.greenAccent : Colors.redAccent,
            ),
            onPressed: () {
              // TODO: कनेक्ट करने का लॉजिक (अगली फाइल में)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Searching for OBD2 Scanner...')),
              );
            },
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vehicle Health Score Section
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNeonBlue.withOpacity(0.15),
                        blurRadius: 30,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CircularProgressIndicator(
                          value: healthScore / 100,
                          strokeWidth: 10,
                          color: AppColors.primaryNeonBlue,
                          backgroundColor: Colors.white10,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            '$healthScore%',
                            style: GoogleFonts.orbitron(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            'HEALTH',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: Colors.white54,
                              letterSpacing: 2.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Telemetry Grid Header
              Text(
                'LIVE TELEMETRY',
                style: GoogleFonts.spaceGrotesk(
                  color: Colors.white70,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 15),
              
              // 4 Live Data Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.4,
                children: [
                  _buildTelemetryCard('RPM', '0', 'rev/min', Icons.speed),
                  _buildTelemetryCard('SPEED', '0', 'km/h', Icons.directions_car),
                  _buildTelemetryCard('TEMP', '---', '°C', Icons.thermostat),
                  _buildTelemetryCard('BATTERY', '12.4', 'V', Icons.battery_charging_full),
                ],
              ),
              const SizedBox(height: 40),

              // Glowing "Scan Now" Button
              SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeonBlue.withOpacity(0.1),
                    side: const BorderSide(color: AppColors.primaryNeonBlue, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 10,
                    shadowColor: AppColors.primaryNeonBlue.withOpacity(0.5),
                  ),
                  onPressed: () {
                    // TODO: AI डायग्नोस्टिक स्कैन शुरू करें
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.document_scanner_outlined, color: AppColors.primaryNeonBlue),
                      const SizedBox(width: 10),
                      Text(
                        'START DIAGNOSTIC SCAN',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNeonBlue,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // कस्टम विजेट फंक्शन: कार्ड्स बनाने के लिए
  Widget _buildTelemetryCard(String title, String value, String unit, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B), // डार्क कार्ड बैकग्राउंड
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12),
              ),
            ],
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Text(
                  unit,
                  style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
