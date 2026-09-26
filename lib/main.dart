import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // असली Firebase पैकेज

import 'providers/ai_chat_provider.dart';
import 'providers/obd_provider.dart';
import 'providers/vehicle_provider.dart';
import 'services/auth_service.dart';
import 'routes/app_routes.dart';

void main() async {
  // ऐप स्टार्ट होने से पहले विजेट्स और Firebase को रेडी करना जरूरी है
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 

  runApp(const MechaniQApp());
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
        ChangeNotifierProvider(create: (_) => ObdProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
      ],
      child: MaterialApp(
        title: 'MechaniQ',
        theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: const Color(0xFF121212),
          primaryColor: Colors.blue,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1E1E1E),
            elevation: 0,
          ),
        ),
        initialRoute: AppRoutes.loginRoute,
        routes: AppRoutes.getRoutes(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
