import 'dart:async';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class ObdTelemetry {
  final double rpm;
  final double speed;
  final double coolantTemp;
  final double voltage;

  ObdTelemetry({
    required this.rpm,
    required this.speed,
    required this.coolantTemp,
    required this.voltage,
  });
}

class ObdService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _writeCharacteristic;
  BluetoothCharacteristic? _readCharacteristic;
  
  StreamSubscription<List<int>>? _readSubscription;
  final StreamController<ObdTelemetry> _telemetryStreamController = StreamController<ObdTelemetry>.broadcast();

  Stream<ObdTelemetry> get telemetryStream => _telemetryStreamController.stream;

  Future<void> startOBDScan() async {
    await FlutterBluePlus.startScan(
      withServices: [Guid("00001101-0000-1000-8000-00805f9b34fb")], // Serial Port Profile (SPP) UUID typically used by ELM327
      timeout: const Duration(seconds: 10),
    );
  }

  Future<bool> connectToObd(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      
      List<BluetoothService> services = await device.discoverServices();
      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            _writeCharacteristic = characteristic;
          }
          if (characteristic.properties.notify || characteristic.properties.indicate) {
            _readCharacteristic = characteristic;
            await characteristic.setNotifyValue(true);
            _listenToDataStream(characteristic);
          }
        }
      }

      if (_writeCharacteristic != null && _readCharacteristic != null) {
        await initializeElm327();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  void _listenToDataStream(BluetoothCharacteristic characteristic) {
    _readSubscription = characteristic.lastValueStream.listen((value) {
      _parseRawObdData(value);
    });
  }

  Future<void> initializeElm327() async {
    // Standard initialization AT commands sequence for ELM327
    await _sendCommand('ATZ\r');    // Reset All
    await _sendCommand('ATE0\r');   // Echo off
    await _sendCommand('ATL0\r');   // Linefeeds off
    await _sendCommand('ATSP0\r');  // Protocol Select Auto
  }

  Future<void> _sendCommand(String cmd) async {
    if (_writeCharacteristic != null) {
      final List<int> bytes = cmd.codeUnits;
      await _writeCharacteristic!.write(bytes, withoutResponse: false);
    }
  }

  /// Read dynamic Engine Parameters from OBD-II
  Future<void> requestTelemetryFrame() async {
    await _sendCommand('010C\r'); // Request Engine Speed (RPM)
    await Future.delayed(const Duration(milliseconds: 100));
    await _sendCommand('010D\r'); // Request Vehicle Speed
    await Future.delayed(const Duration(milliseconds: 100));
    await _sendCommand('0105\r'); // Request Engine Coolant Temp
    await Future.delayed(const Duration(milliseconds: 100));
    await _sendCommand('0142\r'); // Request Control Module Voltage
  }

  void _parseRawObdData(List<int> rawBytes) {
    final String responseStr = String.fromCharCodes(rawBytes).trim();
    if (responseStr.isEmpty || responseStr.contains('NO DATA') || responseStr.contains('?')) {
      return;
    }

    // Clean OBD-II spacing
    final String sanitized = responseStr.replaceAll(' ', '');
    
    double rpm = 0.0;
    double speed = 0.0;
    double temp = 0.0;
    double voltage = 12.6;

    // Direct string matching and Hex parsing (Strictly avoiding JSON serialization)
    if (sanitized.contains('410C')) { // Mode 1 PID 0C Engine RPM Response
      final int idx = sanitized.indexOf('410C');
      if (sanitized.length >= idx + 8) {
        final String hexBytes = sanitized.substring(idx + 4, idx + 8);
        final int? a = int.tryParse(hexBytes.substring(0, 2), radix: 16);
        final int? b = int.tryParse(hexBytes.substring(2, 4), radix: 16);
        if (a != null && b != null) {
          rpm = ((a * 256) + b) / 4.0;
        }
      }
    } else if (sanitized.contains('410D')) { // Mode 1 PID 0D Vehicle Speed Response
      final int idx = sanitized.indexOf('410D');
      if (sanitized.length >= idx + 6) {
        final String hexByte = sanitized.substring(idx + 4, idx + 6);
        final int? a = int.tryParse(hexByte, radix: 16);
        if (a != null) {
          speed = a.toDouble();
        }
      }
    } else if (sanitized.contains('4105')) { // Mode 1 PID 05 Coolant Temperature Response
      final int idx = sanitized.indexOf('4105');
      if (sanitized.length >= idx + 6) {
        final String hexByte = sanitized.substring(idx + 4, idx + 6);
        final int? a = int.tryParse(hexByte, radix: 16);
        if (a != null) {
          temp = (a - 40).toDouble();
        }
      }
    } else if (sanitized.contains('4142')) { // Mode 1 PID 42 Control Module Voltage Response
      final int idx = sanitized.indexOf('4142');
      if (sanitized.length >= idx + 8) {
        final String hexBytes = sanitized.substring(idx + 4, idx + 8);
        final int? a = int.tryParse(hexBytes.substring(0, 2), radix: 16);
        final int? b = int.tryParse(hexBytes.substring(2, 4), radix: 16);
        if (a != null && b != null) {
          voltage = ((a * 256) + b) / 1000.0;
        }
      }
    }

    _telemetryStreamController.add(ObdTelemetry(
      rpm: rpm,
      speed: speed,
      coolantTemp: temp,
      voltage: voltage,
    ));
  }

  Future<void> disconnect() async {
    await _readSubscription?.cancel();
    if (_connectedDevice != null) {
      await _connectedDevice!.disconnect();
      _connectedDevice = null;
    }
  }
}