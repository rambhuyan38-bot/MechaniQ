import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart'; 
import '../utils/app_colors.dart';
import 'login_screen.dart'; // <-- यहाँ बदलाव हुआ है: अब यह LoginScreen को इम्पोर्ट कर रहा है

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkPermissionsAndNavigate(); 
  }

  // Permission Logic
  Future<void> _checkPermissionsAndNavigate() async {
    // 3 सेकंड तक आपका शानदार एनिमेशन दिखाएगा
    await Future.delayed(const Duration(seconds: 3));

    // Bluetooth और Location की परमिशन माँगेगा
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();

    bool allGranted = true;
    statuses.forEach((permission, status) {
      if (!status.isGranted) {
        allGranted = false;
      }
    });

    // अगर सारी परमिशन मिल गईं, तो LoginScreen पर ले जाएगा
    if (allGranted) {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => const LoginScreen(), // <-- यहाँ बदलाव हुआ है: Onboarding की जगह LoginScreen आ गया
            transitionDuration: const Duration(milliseconds: 800),
            transitionsBuilder: (context, anim, secondAnim, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    } else {
      // अगर परमिशन नहीं मिली, तो वार्निंग डायलॉग दिखाएगा
      if (mounted) {
        _showPermissionDialog();
      }
    }
  }

  // Premium Warning Dialog (डार्क थीम के साथ)
  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14243B),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: AppColors.primaryNeonBlue, width: 1.5),
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Access Required",
            style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "MechaniQ requires Location and Bluetooth permissions to scan and connect to your vehicle's OBD2 device.",
            style: GoogleFonts.spaceGrotesk(color: Colors.white70),
          ),
          actions: [
            TextButton(
              child: Text("Settings", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontWeight: FontWeight.bold)),
              onPressed: () {
                openAppSettings(); 
              },
            ),
            TextButton(
              child: Text("Retry", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.pop(context);
                _checkPermissionsAndNavigate(); 
              },
            ),
          ],
        );
      },
    );
  }

  // आपका ओरिजिनल शानदार UI (इसमें कोई बदलाव नहीं किया है)
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.2,
                colors: [
                  Color(0xFF14243B),
                  AppColors.darkBackground,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primaryNeonBlue, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryNeonBlue.withOpacity(0.2),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_outlined,
                    size: 80.0,
                    color: AppColors.primaryNeonBlue,
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'MECHANIQ',
                  style: GoogleFonts.orbitron(
                    fontSize: 40.0,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: 4.0,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Elite AI OBD2 Diagnostics',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 16.0,
                    color: AppColors.primaryNeonBlue,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 50),
                const SpinKitSquareCircle(
                  color: AppColors.primaryNeonBlue,
                  size: 40.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
