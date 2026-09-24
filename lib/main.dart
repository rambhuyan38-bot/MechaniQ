import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'localization/app_localizations.dart';
import 'services/obd_service.dart';
import 'services/cloudflare_ai_service.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        Provider<ObdService>(create: (_) => ObdService()),
        Provider<CloudflareAIService>(create: (_) => CloudflareAIService()),
        ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),
      ],
      child: const MechaniQApp(),
    ),
  );
}

class LocaleProvider with ChangeNotifier {
  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  void changeLocale(String code) {
    _locale = Locale(code);
    notifyListeners();
  }
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProv = Provider.of<LocaleProvider>(context);

    return MaterialApp(
      title: 'MechaniQ',
      debugShowCheckedModeBanner: false,
      locale: localeProv.locale,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('hi', ''),
        Locale('mr', ''),
        Locale('ta', ''),
      ],
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0B0C10),
        primaryColor: const Color(0xFF00F2FE),
        cardColor: const Color(0xFF1F2833),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00F2FE),
          secondary: Color(0xFF00FF87),
          surface: Color(0xFF1F2833),
          background: const Color(0xFF0B0C10),
        ),
        textTheme: const TextTheme(
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24),
          bodyLarge: TextStyle(color: Color(0xFFC5C6C7), fontSize: 16),
          bodyMedium: TextStyle(color: Color(0xFFC5C6C7), fontSize: 14),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}