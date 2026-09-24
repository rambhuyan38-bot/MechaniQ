import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'multi_view_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late StreamController<Map<String, double>> _telemetryController;
  Timer? _telemetryTimer;
  final Random _random = Random();

  double _batteryVoltage = 13.8;
  double _engineTemp = 92.0;
  double _rpm = 2400.0;
  double _speed = 65.0;
  double _healthScore = 94.0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _telemetryController = StreamController<Map<String, double>>.broadcast();
    _startTelemetryMock();
  }

  void _startTelemetryMock() {
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      _batteryVoltage = 13.5 + _random.nextDouble() * 1.2;
      _engineTemp = 88.0 + _random.nextDouble() * 12.0;
      _rpm = 1800.0 + _random.nextDouble() * 1200.0;
      _speed = 50.0 + _random.nextDouble() * 40.0;
      
      if (_engineTemp > 98.0 || _batteryVoltage < 13.6) {
        _healthScore = max(70.0, _healthScore - 0.5);
      } else {
        _healthScore = min(100.0, _healthScore + 0.2);
      }

      if (!_telemetryController.isClosed) {
        _telemetryController.add({
          'battery': _batteryVoltage,
          'temp': _engineTemp,
          'rpm': _rpm,
          'speed': _speed,
          'health': _healthScore,
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _telemetryTimer?.cancel();
    _telemetryController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0A0E14), Color(0xFF121B29)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: StreamBuilder<Map<String, double>>(
            stream: _telemetryController.stream,
            initialData: {
              'battery': _batteryVoltage,
              'temp': _engineTemp,
              'rpm': _rpm,
              'speed': _speed,
              'health': _healthScore,
            },
            builder: (context, snapshot) {
              final data = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    _buildHeader(),
                    const SizedBox(height: 30),
                    _buildHealthScoreWidget(data['health']!),
                    const SizedBox(height: 40),
                    Expanded(
                      child: _buildTelemetryGrid(data),
                    ),
                    _buildScanButton(context),
                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'MECHANIQ',
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.black,
                fontSize: 26,
                letterSpacing: 2,
                color: Color(0xFF00FFCC),
              ),
            ),
            Text(
              'AI Vehicle Diagnostician',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, py: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF151D2A),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.wifi_tethering, color: Color(0xFF00FFCC), size: 16),
              SizedBox(width: 6),
              Text(
                'OBD-II LIVE',
                style: TextStyle(
                  color: Color(0xFF00FFCC),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildHealthScoreWidget(double score) {
    Color scoreColor = const Color(0xFF00FFCC);
    if (score < 80) {
      scoreColor = const Color(0xFFFFB300);
    } else if (score < 60) {
      scoreColor = const Color(0xFFFF3366);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.05),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: score / 100,
                  strokeWidth: 10,
                  backgroundColor: Colors.white.withOpacity(0.05),
                  valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    score.toStringAsFixed(0),
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'HEALTH',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Diagnostic Status',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  score >= 90
                      ? 'All Systems Nominal'
                      : score >= 75
                          ? 'Minor Attention Required'
                          : 'Critical Faults Detected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Continuous real-time stream analysis of OBD-II signals active.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(Map<String, double> data) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildTelemetryCard(
          'BATTERY',
          '${data['battery']!.toStringAsFixed(1)} V',
          Icons.battery_charging_full_rounded,
          const Color(0xFF00E5FF),
        ),
        _buildTelemetryCard(
          'ENGINE TEMP',
          '${data['temp']!.toStringAsFixed(0)} °C',
          Icons.thermostat_rounded,
          const Color(0xFFFFB300),
        ),
        _buildTelemetryCard(
          'RPM',
          data['rpm']!.toStringAsFixed(0),
          Icons.speed_rounded,
          const Color(0xFF00FFCC),
        ),
        _buildTelemetryCard(
          'SPEED',
          '${data['speed']!.toStringAsFixed(0)} km/h',
          Icons.speedometer,
          const Color(0xFFFF3366),
        ),
      ],
    );
  }

  Widget _buildTelemetryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151D2A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                  color: Colors.grey,
                ),
              ),
              Icon(icon, color: color, size: 20),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00FFCC).withOpacity(0.15 * _pulseController.value),
                blurRadius: 20,
                spreadRadius: 10 * _pulseController.value,
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MultiViewResultsScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00FFCC),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 5,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.radar_rounded, size: 24, color: Colors.black),
                SizedBox(width: 10),
                Text(
                  'SCAN NOW',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.black,
                    letterSpacing: 2,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}