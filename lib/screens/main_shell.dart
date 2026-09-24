import 'package:flutter/material.dart';
import 'dashboard_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  final List<Widget> _screens = [
    const DashboardScreen(),
    const Center(child: Text('AI Chat Terminal', style: TextStyle(fontSize: 22, color: Colors.blue))),
    const Center(child: Text('OBD Link Live Scanner', style: TextStyle(fontSize: 22, color: Colors.orange))),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_customize), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_input_antenna), label: 'OBD Scan'),
        ],
      ),
    );
  }
}