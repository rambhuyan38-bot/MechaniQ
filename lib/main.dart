import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'utils/theme.dart';
import 'providers/obd_provider.dart';
import 'providers/vehicle_provider.dart';
import 'providers/ai_chat_provider.dart';
import 'screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => ObdProvider()),
        ChangeNotifierProvider(create: (_) => AIChatProvider()),
      ],
      child: const MechaniQApp(),
    ),
  );
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechaniQ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}