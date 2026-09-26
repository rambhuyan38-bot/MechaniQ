import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // डेटा वेरिएबल्स
  int _health = 95;
  int _rpm = 0;
  int _speed = 0;
  int _temp = 0;
  double _battery = 12.0;
  
  bool _isScanningECU = false;
  bool _isConnected = false;
  bool _isSearchingBluetooth = false; 
  
  Timer? _telemetryTimer;
  final Random _random = Random();
  
  BluetoothDevice? _obdDevice; 
  BluetoothCharacteristic? _writeCharacteristic; 
  BluetoothCharacteristic? _readCharacteristic;  

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    _obdDevice?.disconnect();
    super.dispose();
  }

  // 1. ब्लूटूथ खोजना
  void _scanAndConnectOBD() async {
    setState(() => _isSearchingBluetooth = true);

    if (await FlutterBluePlus.adapterState.first != BluetoothAdapterState.on) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("कृपया पहले फोन का Bluetooth चालू करें!"), backgroundColor: Colors.redAccent));
      setState(() => _isSearchingBluetooth = false);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Searching for ELM327 Scanner..."), backgroundColor: Colors.orangeAccent));
    await FlutterBluePlus.startScan(timeout: Duration(seconds: 4));

    FlutterBluePlus.scanResults.listen((results) async {
      for (ScanResult r in results) {
        if (r.device.platformName.toUpperCase().contains("OBD") || r.device.platformName.toUpperCase().contains("ELM")) {
          FlutterBluePlus.stopScan();
          _obdDevice = r.device;
          
          try {
            await _obdDevice!.connect();
            await _setupObdChannels(); 
            
            setState(() {
              _isConnected = true;
              _isSearchingBluetooth = false;
            });
            
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("OBD2 Connected! Reading Live ECU Data..."), backgroundColor: Colors.green));
            _startRealObdTelemetry(); 
            return;
          } catch (e) {
            print("Connection failed: $e");
          }
        }
      }
    });

    // सेफ्टी फॉलबैक (अगर असली स्कैनर न मिले)
    Future.delayed(Duration(seconds: 5), () {
      if (!_isConnected && mounted) {
        FlutterBluePlus.stopScan();
        setState(() {
          _isConnected = true; 
          _isSearchingBluetooth = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Scanner. Running UI in Safe Mode."), backgroundColor: Colors.blueAccent));
        _startDemoTelemetry();
      }
    });
  }

  Future<void> _setupObdChannels() async {
    if (_obdDevice == null) return;
    List<BluetoothService> services = await _obdDevice!.discoverServices();
    
    for (BluetoothService service in services) {
      for (BluetoothCharacteristic characteristic in service.characteristics) {
        if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
          _writeCharacteristic = characteristic; 
        }
        if (characteristic.properties.notify || characteristic.properties.read) {
          _readCharacteristic = characteristic; 
          await characteristic.setNotifyValue(true);
          
          characteristic.lastValueStream.listen((value) {
            _processRealObdResponse(value); // 🚀 असली डिकोडर में भेजना
          });
        }
      }
    }
  }

  void _startRealObdTelemetry() {
    int step = 0;
    _telemetryTimer = Timer.periodic(Duration(milliseconds: 1000), (timer) async {
      if (_writeCharacteristic == null) return;
      try {
        if (step == 0) await _writeCharacteristic!.write(utf8.encode("010C\r")); // RPM
        else if (step == 1) await _writeCharacteristic!.write(utf8.encode("010D\r")); // Speed
        else if (step == 2) await _writeCharacteristic!.write(utf8.encode("0105\r")); // Temp
        step = (step + 1) % 3;
      } catch (e) {}
    });
  }

  // 🚀 फाइनल: असली HEX to Math Decoder (अब कोई रैंडम डेमो नहीं)
  void _processRealObdResponse(List<int> value) {
    // गाड़ी से आए हेक्स कोड को साफ करना (e.g., "41 0C 1A F8" -> "410C1AF8")
    String response = utf8.decode(value).trim().replaceAll(' ', '').toUpperCase();
    
    if(mounted) {
      setState(() {
        try {
          // 🚘 RPM डिकोडिंग (Formula: ((A * 256) + B) / 4)
          if (response.startsWith("410C") && response.length >= 8) {
            int a = int.parse(response.substring(4, 6), radix: 16);
            int b = int.parse(response.substring(6, 8), radix: 16);
            _rpm = ((a * 256) + b) ~/ 4;
          } 
          // 🚘 SPEED डिकोडिंग (Formula: A)
          else if (response.startsWith("410D") && response.length >= 6) {
            int a = int.parse(response.substring(4, 6), radix: 16);
            _speed = a;
          } 
          // 🚘 TEMP डिकोडिंग (Formula: A - 40)
          else if (response.startsWith("4105") && response.length >= 6) {
            int a = int.parse(response.substring(4, 6), radix: 16);
            _temp = a - 40;
          }
          // 🚘 FAULT CODES (DTC) डिकोडिंग (03 Command का जवाब '43' से शुरू होता है)
          else if (response.startsWith("43")) {
            _parseAndShowFaultCodes(response);
          }
        } catch (e) {
          print("Parse Error: $e");
        }
      });
    }
  }

  // 🚀 फाइनल: असली Fault Code Parser
  void _parseAndShowFaultCodes(String hexResponse) {
    // अगर जवाब "43 00 00 00" है, मतलब कोई खराबी नहीं
    if (hexResponse.contains("4300")) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("स्कैन पूरा हुआ! ECU में कोई फॉल्ट नहीं है।", style: GoogleFonts.spaceGrotesk()), backgroundColor: Colors.green));
      return;
    }
    
    // अगर खराबी है, तो कोड निकालना (e.g., P0300)
    // (यहाँ एडवांस्ड P, C, B, U कोड पार्सिंग की जाती है, अभी के लिए अलर्ट शो करेंगे)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF161B22),
        title: Text("⚠️ Engine Fault Detected!", style: GoogleFonts.orbitron(color: Colors.redAccent)),
        content: Text("गाड़ी के ECU से फॉल्ट कोड (DTC) मिला है। अधिक जानकारी और सही फिक्स के लिए MechaniQ AI से बात करें या मैकेनिक बुक करें।", style: GoogleFonts.spaceGrotesk(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("CLOSE", style: TextStyle(color: Colors.white54))),
          TextButton(onPressed: () => Navigator.pop(context), child: Text("ASK AI", style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  void _runDiagnosticScan() async {
    setState(() => _isScanningECU = true);

    if (_writeCharacteristic != null) {
      // गाड़ी से असली फॉल्ट कोड मांगना
      await _writeCharacteristic!.write(utf8.encode("03\r"));
      
      // 5 सेकंड इंतज़ार करना ताकि गाड़ी '43' वाला जवाब भेज दे
      Future.delayed(Duration(seconds: 5), () {
        if(mounted) setState(() => _isScanningECU = false);
      });
    } else {
      // अगर स्कैनर नहीं लगा है, तो सेफ मोड मैसेज
      Future.delayed(Duration(seconds: 3), () {
        if(mounted) setState(() => _isScanningECU = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("[Demo] स्कैन पूरा! स्कैनर कनेक्ट करें।", style: GoogleFonts.spaceGrotesk()), backgroundColor: Colors.orangeAccent));
      });
    }
  }

  void _startDemoTelemetry() {
    _telemetryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _rpm = 800 + _random.nextInt(50); 
          _battery = 13.8 + (_random.nextDouble() * 0.4); 
          _temp = 90 + _random.nextInt(3); 
          if (_random.nextInt(10) > 7) _health = 94 + _random.nextInt(3); 
        });
      }
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
          IconButton(
            onPressed: (_isConnected || _isSearchingBluetooth) ? null : _scanAndConnectOBD,
            icon: _isSearchingBluetooth 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.orangeAccent, strokeWidth: 2))
                : Icon(_isConnected ? Icons.bluetooth_connected : Icons.bluetooth_searching, color: _isConnected ? Colors.blueAccent : Colors.redAccent),
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
              // HEALTH CIRCLE
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
              
              // TELEMETRY GRID
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
              
              // SCAN BUTTON
              ElevatedButton(
                onPressed: (_isConnected && !_isScanningECU) ? _runDiagnosticScan : null,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: _isConnected ? Colors.cyanAccent : Colors.white24)), padding: EdgeInsets.symmetric(vertical: 20)),
                child: _isScanningECU 
                    ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)), SizedBox(width: 16), Text("SCANNING ECU...", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold))])
                    : Text("START DIAGNOSTIC SCAN", style: GoogleFonts.orbitron(color: _isConnected ? Colors.cyanAccent : Colors.white54, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
              ),
              SizedBox(height: 16),
              
              // Amazon Affiliate Button
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
