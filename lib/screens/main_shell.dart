import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';
import 'diagnostics_screen.dart';
import 'garage_screen.dart';
import 'ai_assistant_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const DiagnosticsScreen(),
    const AIAssistantScreen(),
    const GarageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(
            top: BorderSide(color: AppColors.borderCyan, width: 1.0),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: AppColors.darkBackground,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primaryNeonBlue,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.0),
          unselectedLabelStyle: const TextStyle(fontSize: 11.0),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard, color: AppColors.primaryNeonBlue),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.troubleshoot_outlined),
              activeIcon: Icon(Icons.troubleshoot, color: AppColors.primaryNeonBlue),
              label: 'OBD Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.psychology_outlined),
              activeIcon: Icon(Icons.psychology, color: AppColors.primaryNeonBlue),
              label: 'AI Mechanic',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.garage_outlined),
              activeIcon: Icon(Icons.garage, color: AppColors.primaryNeonBlue),
              label: 'Garage',
            ),
          ],
        ),
      ),
    );
  }
}