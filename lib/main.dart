import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'lib/screens/login_screen.dart';
import 'lib/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Safe Firebase Initialization for development setup
  try {
    await Firebase.initializeApp();
    await FirebaseAppCheck.instance.activate(
      webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    );
  } catch (e) {
    debugPrint("Firebase initialization bypassed or failed: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
      ],
      child: const MechaniQApp(),
    ),
  );
}

class AppStateProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String _selectedVehicle = "";

  bool get isAuthenticated => _isAuthenticated;
  String get selectedVehicle => _selectedVehicle;

  void authenticate(bool value) {
    _isAuthenticated = value;
    notifyListeners();
  }

  void updateVehicle(String vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechaniQ',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0B10),
        primaryColor: const Color(0xFF00FFCC),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFCC),
          secondary: Color(0xFF00E5FF),
          background: Color(0xFF0A0B10),
          surface: Color(0xFF121420),
          onBackground: Colors.white,
          onSurface: Colors.white70,
        ),
        textTheme: GoogleFonts.orbitronTextTheme(
          ThemeData.dark().textTheme,
        ).copyWith(
          bodyLarge: GoogleFonts.shareTechMono(
            fontSize: 18,
            color: Colors.white,
          ),
          bodyMedium: GoogleFonts.shareTechMono(
            fontSize: 15,
            color: Colors.white70,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF16192B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1F2444)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1F2444)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00FFCC), width: 1.5),
          ),
          labelStyle: GoogleFonts.shareTechMono(color: Colors.white60),
          hintStyle: GoogleFonts.shareTechMono(color: Colors.white30),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00FFCC),
            foregroundColor: const Color(0xFF0A0B10),
            shadowColor: const Color(0xFF00FFCC).withOpacity(0.5),
            elevation: 10,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: GoogleFonts.orbitron(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const DummyHomeScreen(),
      },
    );
  }
}

class DummyHomeScreen extends StatelessWidget {
  const DummyHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = Provider.of<AppStateProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('MECHANIQ DASHBOARD', style: GoogleFonts.orbitron(color: const Color(0xFF00FFCC))),
        backgroundColor: const Color(0xFF121420),
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, color: Color(0xFF00E5FF), size: 100),
              const SizedBox(height: 24),
              Text(
                'SYSTEM ACTIVATED',
                style: GoogleFonts.orbitron(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Configured Vehicle: ${state.selectedVehicle.isEmpty ? "None" : state.selectedVehicle}',
                textAlign: TextAlign.center,
                style: GoogleFonts.shareTechMono(fontSize: 18, color: const Color(0xFF00FFCC)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}