import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'main_shell.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMain();
  }

  void _navigateToMain() async {
    await Future.delayed(const Duration(seconds: 3));
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => const MainShell(),
        transitionDuration: const Duration(milliseconds: 800),
        transitionsBuilder: (context, anim, secondAnim, child) {
          return FadeTransition(opacity: anim, child: child);
        },
      ),
    );
  }

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