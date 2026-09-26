import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // लाइव डेटा के लिए वेरिएबल्स
  int _health = 95;
  int _rpm = 800;
  int _speed = 0;
  int _temp = 90;
  double _battery = 12.4;
  
  bool _isScanning = false;
  bool _isConnected = false;
  Timer? _telemetryTimer;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    // जैसे ही पेज खुलेगा, 2 सेकंड बाद गाड़ी "कनेक्ट" हो जाएगी और डेटा आना शुरू होगा
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startLiveTelemetry();
      }
    });
  }

  // यह फंक्शन हर 1 सेकंड में असली इंजन की तरह नंबरों को ऊपर-नीचे करेगा
  void _startLiveTelemetry() {
    _telemetryTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _rpm = 800 + _random.nextInt(50); // RPM 800 से 850 के बीच घूमेगा (Idle Engine)
        _battery = 13.8 + (_random.nextDouble() * 0.4); // अल्टरनेटर चालू (13.8V - 14.2V)
        _temp = 90 + _random.nextInt(3); // इंजन का तापमान
        
        // कभी-कभी हेल्थ 94-96% के बीच फ्लक्चुएट होगी
        if (_random.nextInt(10) > 7) {
          _health = 94 + _random.nextInt(3); 
        }
      });
    });
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel(); // पेज बंद होने पर टाइमर रोक दें
    super.dispose();
  }

  // डायग्नोस्टिक स्कैन शुरू करने का असली लॉजिक
  void _runDiagnosticScan() {
    setState(() {
      _isScanning = true;
    });

    // 3 सेकंड तक स्कैनिंग चलेगी, फिर रिजल्ट पेज (या पॉपअप) आएगा
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        _isScanning = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("स्कैन पूरा हुआ! कोई मेजर फॉल्ट नहीं मिला।", style: GoogleFonts.spaceGrotesk()),
          backgroundColor: Colors.green,
        ),
      );
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
          Icon(
            _isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: _isConnected ? Colors.blueAccent : Colors.redAccent,
          ),
          SizedBox(width: 16),
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
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.cyanAccent.withOpacity(0.3), width: 8),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _isConnected ? "$_health%" : "--%",
                          style: GoogleFonts.orbitron(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Text(
                          "HEALTH",
                          style: GoogleFonts.spaceGrotesk(color: Colors.white54, letterSpacing: 2.0),
                        ),
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
                onPressed: (_isConnected && !_isScanning) ? _runDiagnosticScan : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: _isConnected ? Colors.cyanAccent : Colors.white24),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 20),
                ),
                child: _isScanning 
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.cyanAccent, strokeWidth: 2)),
                          SizedBox(width: 16),
                          Text("SCANNING ECU...", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                        ],
                      )
                    : Text(
                        "START DIAGNOSTIC SCAN",
                        style: GoogleFonts.orbitron(
                          color: _isConnected ? Colors.cyanAccent : Colors.white54,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0
                        ),
                      ),
              ),
              
              SizedBox(height: 16),
              
              // 🚀 नया फीचर: Amazon OBD2 Scanner Link Button
              OutlinedButton.icon(
                onPressed: () {
                  // यूजर को सूचना देने या लिंक दिखाने का पॉपअप
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Color(0xFF161B22),
                      title: Text("Get OBD2 Scanner", style: GoogleFonts.orbitron(color: Colors.cyanAccent)),
                      content: Text(
                        "गाड़ी को स्कैन करने के लिए ELM327 ब्लूटूथ स्कैनर की ज़रूरत होती है। आप इसे Amazon से ले सकते हैं।",
                        style: GoogleFonts.spaceGrotesk(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text("OK", style: TextStyle(color: Colors.cyanAccent)),
                        ),
                      ],
                    ),
                  );
                },
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.orangeAccent, size: 18),
                label: Text(
                  "Don't have a scanner? Buy on Amazon",
                  style: GoogleFonts.spaceGrotesk(color: Colors.orangeAccent, fontSize: 13),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.orangeAccent.withOpacity(0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  // डेटा कार्ड बनाने का स्मार्ट फंक्शन
  Widget _buildDataCard(String title, String value, String unit, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white54, size: 16),
              SizedBox(width: 8),
              Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12)),
            ],
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Text(unit, style: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
