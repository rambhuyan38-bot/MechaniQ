import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'dashboard_screen.dart';
import 'garage_screen.dart';
import 'ai_assistant_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({Key? key}) : super(key: key);

  @override
  _MainShellState createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // यह तीनों स्क्रीन हमारे नेविगेशन से जुड़ी रहेंगी
  final List<Widget> _screens = [
    const DashboardScreen(),
    const GarageScreen(),
    const AiAssistantScreen(), // AI Chat स्क्रीन
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      // IndexedStack का इस्तेमाल ताकि पेज स्विच करते समय स्टेट (डेटा) रिसेट न हो
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryNeonBlue.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF14243B), // डार्क प्रीमियम नेविगेशन बैकग्राउंड
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primaryNeonBlue,
            unselectedItemColor: Colors.white54,
            selectedLabelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12),
            unselectedLabelStyle: GoogleFonts.spaceGrotesk(fontSize: 11),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.speed_outlined),
                activeIcon: Icon(Icons.speed, size: 28),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.garage_outlined),
                activeIcon: Icon(Icons.garage, size: 28),
                label: 'Garage',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.smart_toy_outlined),
                activeIcon: Icon(Icons.smart_toy, size: 28),
                label: 'AI Chat',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
