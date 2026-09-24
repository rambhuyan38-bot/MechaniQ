import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/main_shell.dart';
import '../screens/dashboard_screen.dart';

class AppRoutes {
  static const String loginRoute = '/';
  static const String mainShellRoute = '/main';
  static const String dashboardRoute = '/dashboard';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      loginRoute: (context) => const LoginScreen(),
      mainShellRoute: (context) => const MainShell(),
      dashboardRoute: (context) => const DashboardScreen(),
    };
  }
}