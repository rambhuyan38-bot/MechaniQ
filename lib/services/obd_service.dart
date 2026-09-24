import 'dart:async';
import 'dart:math';
import '../database/db_helper.dart';
import '../models/vehicle.dart';

class ObdService {
  bool _isConnected = false;
  String _connectionType = "None"; // Bluetooth, BLE, Wi-Fi
  final _telemetryStreamController = StreamController<Map<String, double>>.broadcast();

  bool get isConnected => _isConnected;
  String get connectionType => _connectionType;
  Stream<Map<String, double>> get telemetryStream => _telemetryStreamController.stream;

  Future<bool> connect(String type) async {
    _connectionType = type;
    await Future.delayed(const Duration(seconds: 2)); // Simulate connection latency
    _isConnected = true;
    _startTelemetryEmulation();
    return true;
  }

  void disconnect() {
    _isConnected = false;
    _connectionType = "None";
  }

  // Parses Honda custom Init sequences from local SQLite storage
  Future<List<String>> executeHondaInitSequence() async {
    final sequence = await DbHelper.instance.getHondaInitSequence();
    List<String> logs = [];
    for (var step in sequence) {
      String hex = step['hex_command'] as String;
      int delay = step['delay_ms'] as int;
      logs.add("Executing: $hex (Delay: ${delay}ms)");
      await Future.delayed(Duration(milliseconds: delay));
      logs.add("Honda ECU Response: OK/ACK");
    }
    return logs;
  }

  // Parse Raw Hex Response based on PID formulas from DB
  double parseHexRaw(String responseHex, PidMetadata metadata) {
    if (responseHex.length < 2) return 0.0;
    // Mock robust parsing depending on Formula criteria
    if (metadata.formula.contains("((A*256)+B)/4")) {
      int a = int.parse(responseHex.substring(0, 2), radix: 16);
      int b = int.parse(responseHex.substring(2, 4), radix: 16);
      return ((a * 256) + b) / 4.0;
    } else if (metadata.formula.contains("A-40")) {
      int a = int.parse(responseHex.substring(0, 2), radix: 16);
      return (a - 40).toDouble();
    } else if (metadata.formula.contains("A")) {
      int a = int.parse(responseHex.substring(0, 2), radix: 16);
      return a.toDouble();
    }
    return 0.0;
  }

  void _startTelemetryEmulation() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isConnected) {
        timer.cancel();
        return;
      }
      final rand = Random();
      final rpm = 1200.0 + rand.nextDouble() * 3200.0;
      final speed = 40.0 + rand.nextDouble() * 80.0;
      final temp = 85.0 + rand.nextDouble() * 15.0;
      final battery = 13.4 + rand.nextDouble() * 1.1;

      _telemetryStreamController.add({
        'RPM': double.parse(rpm.toStringAsFixed(1)),
        'Speed': double.parse(speed.toStringAsFixed(1)),
        'Temp': double.parse(temp.toStringAsFixed(1)),
        'Battery': double.parse(battery.toStringAsFixed(2))
      });
    });
  }

  Future<List<String>> scanDtcCodes(Vehicle vehicle) async {
    await Future.delayed(const Duration(seconds: 3));
    // Provide diagnostic codes depending on fuel/vehicle type
    if (vehicle.fuelType == 'EV') {
      return ['P0A80'];
    } else {
      return ['P0100', 'P0300'];
    }
  }

  Future<bool> clearDtcCodes() async {
    // Service 04 simulation
    await Future.delayed(const Duration(seconds: 2));
    return true;
  }
}