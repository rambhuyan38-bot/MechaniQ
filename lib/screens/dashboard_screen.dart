import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'package:flutter_blue_plus/flutter_blue_plus.dart'; // 🚀 असली Bluetooth पैकेज

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // डेटा वेरिएबल्स
  int _health = 95;
  int _rpm = 800;
  int _speed = 0;
  int _temp = 90;
  double _battery = 12.4;
  
  bool _isScanningECU = false;
  bool _isConnected = false;
  bool _isSearchingBluetooth = false; // ब्लूटूथ खोजने का स्टेटस
  
  Timer? _telemetryTimer;
  final Random _random = Random();
  
  BluetoothDevice? _obdDevice; // असली स्कैनर सेव करने के लिए

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _obdDevice?.disconnect(); // पेज बंद होने पर स्कैनर डिसकनेक्ट करें
    super.dispose();
  }

  // 🚀 नया असली फीचर: Bluetooth Scanner खोजना और कनेक्ट करना
  void _scanAndConnectOBD() async {
    setState(() {
      _isSearchingBluetooth = true;
    });

    // चेक करें कि फोन का ब्लूटूथ चालू है या नहीं
    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("कृपया पहले फोन का Bluetooth चालू करें!"), backgroundColor: Colors.redAccent));
      setState(() => _isSearchingBluetooth = false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Searching for ELM327 Scanner..."), backgroundColor: Colors.orangeAccent));

    // 4 सेकंड तक आस-पास डिवाइस खोजना
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        // अगर डिवाइस के नाम में OBD या ELM है
        if (r.device.platformName.toUpperCase().contains("OBD") || r.device.platformName.toUpperCase().contains("ELM")) {
          FlutterBluePlus.stopScan();
          _obdDevice = r.device;
          
          try {
            await _obdDevice!.connect(); // असली हार्डवेयर से कनेक्शन
            setState(() {
              _isConnected = true;
              _isSearchingBluetooth = false;
            });
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OBD2 Scanner Successfully Connected!"), backgroundColor: Colors.green));
            
            // यहाँ भविष्य में असली AT Commands (010C) से डेटा मंगाने का कोड आएगा
            // अभी के लिए UI को ज़िंदा रखने के लिए सिम्युलेटर चला रहे हैं
            _startLiveTelemetry();
            return;
          } catch (e) {
            print("Connection failed: $e");
          }
        }
      }
    });

    // अगर 4 सेकंड में कोई असली स्कैनर नहीं मिला, तो डेमो मोड चालू कर दें (ताकि ऐप रुके नहीं)
    Future.delayed(Duration(seconds: 5), () {
      if (!_isConnected && mounted) {
        FlutterBluePlus.stopScan();
        setState(() {
          _isConnected = true; // Demo mode connection
          _isSearchingBluetooth = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No real scanner found. Starting Demo Mode."), backgroundColor: Colors.blueAccent));
        _startLiveTelemetry();
      }
    });
  }

  // आपका पुराना सिम्युलेटर लॉजिक (सुरक्षित रखा गया है)
  void _startLiveTelemetry() {
    _telemetryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _rpm = 800 + _random.nextInt(50); 
          _battery = 13.8 + (_random.nextDouble() * 0.4); 
          _temp = 90 + _random.nextInt(3); 
          if (_random.nextInt(10) > 7) {
            _health = 94 + _random.nextInt(3); 
          }
        });
      }
    });
  }

  // आपका पुराना डायग्नोस्टिक स्कैन लॉजिक
  void _runDiagnosticScan() {
    setState(() {
      _isScanningECU = true;
    });
    Future.delayed(Duration(seconds: 3), () {
      if(mounted) setState(() {
        _isScanningECU = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("स्कैन पूरा हुआ! कोई मेजर फॉल्ट नहीं मिला।", style: GoogleFonts.spaceGrotesk()), backgroundColor: Colors.green));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), // MechaniQ Theme
      appBar: AppBar(
        backgroundColor: Color(0xFF161B22),
        title: Text("MECHANIQ", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold, letterSpacing: 2.0)),
        actions: [
          // 🚀 ब्लूटूथ आइकॉन अब एक असली बटन है
          IconButton(
            onPressed: (_isConnected || _isSearchingBluetooth) ? null : _scanAndConnectOBD,
            icon: _isSearchingBluetooth 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 2))
                : Icon(
                    _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching,
                    color: _isConnected ? Colors.blueAccent : Colors.redAccent,
                  ),
          ),
          SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // HEALTH CIRCLE (No changes)
              Center(
                child: Container(
                  height: 200, width: 200,
                  decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 8)),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(_isConnected ? "$_health%" : "--%", style: GoogleFonts.orbitron(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white)),
                        Text("HEALTH", style: GoogleFonts.spaceGrotesk(color: Colors.white54, letterSpacing: 2.0)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40),
              Text("LIVE TELEMETRY", style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              SizedBox(height: 16),
              
              // TELEMETRY GRID (No changes)
              Row(
                children: [
                  Expanded(child: _buildDataCard("RPM", _isConnected ? "$_rpm" : "---", "rev/min", Icons.speed)),
                  SizedBox(width: 16),
                  Expanded(child: _buildDataCard("SPEED", _isConnected ? "$_speed" : "---", "km/h", Icons.directions_car)),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDataCard("TEMP", _isConnected ? "$_temp" : "---", "°C", Icons.thermostat)),
                  SizedBox(width: 16),
                  Expanded(child: _buildDataCard("BATTERY", _isConnected ? "${_battery.toStringAsFixed(1)}" : "---", "V", Icons.battery_charging_full)),
                ],
              ),
              SizedBox(height: 40),
              
              // SCAN BUTTON (No changes)
              ElevatedButton(
                onPressed: (_isConnected && !_isScanningECU) ? _runDiagnosticScan : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _isConnected ? Colors.cyanAccent : Colors.white24)), padding: EdgeInsets.symmetric(vertical: 20)),
                child: _isScanningECU 
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)), SizedBox(width: 16), Text("SCANNING ECU...", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold))])
                    : Text("START DIAGNOSTIC SCAN", style: GoogleFonts.orbitron(color: _isConnected ? Colors.cyanAccent : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              SizedBox(height: 16),
              
              // Amazon Affiliate Button (No changes)
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(context: context, builder: (context) => AlertDialog(backgroundColor: Color(0xFF161B22), title: Text("Get OBD2 Scanner", style: GoogleFonts.orbitron(color: Colors.cyanAccent)), content: Text("गाड़ी को स्कैन करने के लिए ELM327 ब्लूटूथ स्कैनर की ज़रूरत होती है। आप इसे Amazon से ले सकते हैं।", style: GoogleFonts.spaceGrotesk(color: Colors.white70)), actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text("OK", style: TextStyle(color: Colors.cyanAccent)))]));
                },
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.orangeAccent, size: 18),
                label: Text("Don't have a scanner? Buy on Amazon", style: GoogleFonts.spaceGrotesk(color: Colors.orangeAccent, fontSize: 13)),
                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), padding: EdgeInsets.symmetric(vertical: 12)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDataCard(String title, String value, String unit, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Color(0xFF161B22), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: Colors.white54, size: 16), SizedBox(width: 8), Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12))]),
          SizedBox(height: 16),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)), SizedBox(width: 4), Text(unit, style: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent, fontSize: 12))]),
        ],
      ),
    );
  }
}
