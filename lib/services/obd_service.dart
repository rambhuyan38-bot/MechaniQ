import 'dart:async';
import 'package:flutter/foundation.dart';

class OBDService {
  // Singleton Pattern: ताकि पूरे ऐप में एक ही ब्लूटूथ कनेक्शन रहे
  static final OBDService _instance = OBDService._internal();
  factory OBDService() => _instance;
  OBDService._internal();

  bool isConnected = false;
  String connectedDeviceName = "";

  // डैशबोर्ड पर लाइव डेटा भेजने के लिए Stream
  final _telemetryController = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get telemetryStream => _telemetryController.stream;

  // 1. ELM327 स्कैनर से कनेक्ट करने का लॉजिक
  Future<bool> connectToOBD() async {
    try {
      debugPrint("Searching for ELM327 OBD2 Adapter...");
      
      // TODO: यहाँ असली flutter_bluetooth_serial या BLE का कनेक्शन कोड आएगा
      // अभी के लिए हम 2 सेकंड का डिले दे रहे हैं ताकि 'Connecting' UI फील आए
      await Future.delayed(const Duration(seconds: 2));
      
      isConnected = true;
      connectedDeviceName = "OBDII ELM327 (Mock)";
      
      // कनेक्ट होते ही स्कैनर को इनिशियलाइज़ करें
      await initializeAdapter();
      
      // लाइव डेटा पढ़ना शुरू करें
      _startLiveTelemetry();
      
      return true;
    } catch (e) {
      debugPrint("OBD Connection Error: $e");
      isConnected = false;
      return false;
    }
  }

  // 2. ELM327 को जगाने और सेट करने वाले AT Commands
  Future<void> initializeAdapter() async {
    if (!isConnected) return;
    
    // असली OBD2 प्रोटोकॉल सीक्वेंस
    await _sendCommand("ATZ");    // Scanner Reset
    await Future.delayed(const Duration(milliseconds: 500));
    await _sendCommand("ATE0");   // Echo Off (ताकि फालतू डेटा न आए)
    await _sendCommand("ATL0");   // Linefeeds Off
    await _sendCommand("ATSP0");  // Auto Select Protocol (गाड़ी खुद पहचाने)
  }

  // 3. कमांड भेजना और डेटा पढ़ना
  Future<String> _sendCommand(String command) async {
    // TODO: असली ब्लूटूथ सॉकेट के ज़रिए बाइट्स (Bytes) भेजें
    debugPrint("Sending to OBD: $command");
    return "OK"; 
  }

  // 4. कनेक्शन काटना
  void disconnect() {
    isConnected = false;
    connectedDeviceName = "";
    debugPrint("Disconnected from OBD2 Adapter");
  }

  // --- UI टेस्टिंग के लिए डमी लाइव डेटा (बाद में इसे असली PIDs से बदलेंगे) ---
  void _startLiveTelemetry() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!isConnected) {
        timer.cancel();
        return;
      }
      
      // हर 1 सेकंड में डैशबोर्ड को नया डेटा भेजना
      _telemetryController.add({
        'rpm': (800 + (DateTime.now().millisecond % 1500)).toString(), // 800 से 2300 RPM
        'speed': (20 + (DateTime.now().second % 40)).toString(),        // 20 से 60 KM/H
        'temp': '88',
        'battery': '13.8',
      });
    });
  }
}
