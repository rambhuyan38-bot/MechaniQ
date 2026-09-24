import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MechaniQApp());
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechaniQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E14),
        primaryColor: const Color(0xFF00FFCC),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFCC),
          secondary: Color(0xFF00E5FF),
          surface: Color(0xFF151D2A),
          background: Color(0xFF0A0E14),
          error: Color(0xFFFF3366),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Color(0xFFB0BEC5), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFF90A4AE), fontSize: 14),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}