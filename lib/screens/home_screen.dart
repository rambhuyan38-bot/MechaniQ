import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../services/obd_service.dart';
import '../localization/app_localizations.dart';
import 'multi_view_results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _scannerController;
  bool _isScanning = false;
  String _currentStep = 'Idle';

  @override
  void initState() {
    super.initState();
    _scannerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _triggerDiagnosticScan(Vehicle vehicle) async {
    final obd = Provider.of<ObdService>(context, listen: false);
    if (!obd.isConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please connect to ELM327 Adapter first!')),
      );
      return;
    }

    setState(() {
      _isScanning = true;
      _currentStep = 'Executing Honda Custom Init sequence...';
    });
    
    await obd.executeHondaInitSequence();
    
    setState(() => _currentStep = 'Querying generic/custom PIDs...');
    await Future.delayed(const Duration(seconds: 1));
    
    setState(() => _currentStep = 'Parsing real-time sensors...');
    final dtcs = await obd.scanDtcCodes(vehicle);

    setState(() {
      _isScanning = false;
      _currentStep = 'Idle';
    });

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MultiViewResultsScreen(
          vehicle: vehicle,
          dtcCodes: dtcs,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final obd = Provider.of<ObdService>(context);
    final vehicle = (ModalRoute.of(context)!.settings.arguments as Vehicle?) ??
        Vehicle(type: 'Car', brand: 'Tata', model: 'Nexon', year: 2022, fuelType: 'EV');

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('title'), style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings_input_antenna, color: obd.isConnected ? const Color(0xFF00FF87) : Colors.red),
            onPressed: () => _showConnectionManager(context, obd),
          ),
        ],
      ),
      body: StreamBuilder<Map<String, double>>(
        stream: obd.telemetryStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? {'RPM': 0.0, 'Speed': 0.0, 'Temp': 0.0, 'Battery': 12.6};
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildVehicleHeader(vehicle),
                  const SizedBox(height: 20),
                  _buildHealthIndicator(),
                  const SizedBox(height: 24),
                  _buildTelemetryGrid(data, loc),
                  const SizedBox(height: 40),
                  Center(
                    child: _isScanning
                        ? _buildRadarAnimation()
                        : _buildScanButton(vehicle, loc),
                  ),
                  if (_isScanning) ...[
                    const SizedBox(height: 16),
                    Text(
                      _currentStep,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold),
                    ),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVehicleHeader(Vehicle vehicle) {
    return Card(
      color: const Color(0xFF1F2833),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              vehicle.type == 'EV' ? Icons.electric_car : Icons.directions_car,
              size: 40,
              color: const Color(0xFF00F2FE),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${vehicle.brand} ${vehicle.model}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  '${vehicle.year} | ${vehicle.fuelType} Profile Loaded',
                  style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 13),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildHealthIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF00FF87).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Vehicle Health Status', style: TextStyle(fontSize: 14, color: Color(0xFFC5C6C7))),
              SizedBox(height: 4),
              Text('EXCELLENT', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00FF87))),
            ],
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(
                  value: 0.96,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey[800],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF00FF87)),
                ),
              ),
              const Text('96%', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTelemetryGrid(Map<String, double> data, AppLocalizations loc) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.5,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _telemetryCard(loc.translate('battery_voltage'), '${data['Battery']} V', Icons.battery_charging_full, const Color(0xFF00FF87)),
        _telemetryCard(loc.translate('engine_temp'), '${data['Temp']} °C', Icons.thermostat, Colors.orange),
        _telemetryCard(loc.translate('rpm'), '${data['RPM']}', Icons.speed, const Color(0xFF00F2FE)),
        _telemetryCard(loc.translate('speed'), '${data['Speed']} km/h', Icons.shutter_speed, Colors.purple),
      ],
    );
  }

  Widget _telemetryCard(String title, String val, IconData icon, Color color) {
    return Card(
      color: const Color(0xFF1F2833),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Color(0xFFC5C6C7), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton(Vehicle vehicle, AppLocalizations loc) {
    return GestureDetector(
      onTap: () => _triggerDiagnosticScan(vehicle),
      child: Container(
        width: 160,
        height: 160,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF00F2FE), Color(0xFF00FF87)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00F2FE).withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 5,
            )
          ],
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 48, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              loc.translate('scan_now'),
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRadarAnimation() {
    return AnimatedBuilder(
      animation: _scannerController,
      builder: (context, child) {
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00F2FE).withOpacity(1 - _scannerController.value),
              width: _scannerController.value * 8,
            ),
          ),
          alignment: Alignment.center,
          child: const Icon(Icons.bolt, size: 64, color: Color(0xFF00FF87)),
        );
      },
    );
  }

  void _showConnectionManager(BuildContext context, ObdService obd) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1F2833),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'ELM327 Connection Manager',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _connectionOption(context, obd, 'Bluetooth Classic', Icons.bluetooth),
              _connectionOption(context, obd, 'BLE (Smart Bluetooth)', Icons.bluetooth_searching),
              _connectionOption(context, obd, 'Wi-Fi Socket (192.168.0.10)', Icons.wifi),
              const SizedBox(height: 20),
              if (obd.isConnected)
                ElevatedButton(
                  onPressed: () {
                    obd.disconnect();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('DISCONNECT ADAPTER', style: TextStyle(color: Colors.white)),
                )
            ],
          ),
        );
      },
    );
  }

  Widget _connectionOption(BuildContext context, ObdService obd, String protocol, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FF87)),
      title: Text(protocol, style: const TextStyle(color: Colors.white)),
      trailing: obd.isConnected && obd.connectionType == protocol
          ? const Icon(Icons.check_circle, color: Color(0xFF00FF87))
          : const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () async {
        await obd.connect(protocol);
        Navigator.of(context).pop();
      },
    );
  }
}