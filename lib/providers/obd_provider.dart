import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/telemetry_data.dart';
import '../models/dtc_model.dart';

enum ObdConnectionState { disconnected, searching, connecting, connected }

class ObdProvider with ChangeNotifier {
  ObdConnectionState _connectionState = ObdConnectionState.disconnected;
  TelemetryData _telemetry = TelemetryData.initial();
  bool _isScanning = false;
  List<DiagnosticTroubleCode> _activeCodes = [];
  Timer? _telemetryTimer;
  final Random _random = Random();

  ObdConnectionState get connectionState => _connectionState;
  TelemetryData get telemetry => _telemetry;
  bool get isScanning => _isScanning;
  List<DiagnosticTroubleCode> get activeCodes => _activeCodes;

  void connectOBD() async {
    _connectionState = ObdConnectionState.searching;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _connectionState = ObdConnectionState.connecting;
    notifyListeners();

    await Future.delayed(const Duration(seconds: 2));
    _connectionState = ObdConnectionState.connected;
    _startTelemetryStreaming();
    notifyListeners();
  }

  void disconnectOBD() {
    _connectionState = ObdConnectionState.disconnected;
    _telemetryTimer?.cancel();
    _telemetry = TelemetryData.initial();
    notifyListeners();
  }

  void _startTelemetryStreaming() {
    _telemetryTimer?.cancel();
    _telemetryTimer = Timer.periodic(const Duration(milliseconds: 350), (timer) {
      if (_connectionState == ObdConnectionState.connected) {
        _telemetry = TelemetryData(
          rpm: 2500 + _random.nextDouble() * 800,
          speed: 85.0 + _random.nextDouble() * 5,
          coolantTemp: 90.0 + _random.nextDouble() * 2,
          engineLoad: 45.0 + _random.nextDouble() * 15,
          fuelPressure: 380 + _random.nextDouble() * 20,
          voltage: 13.8 + _random.nextDouble() * 0.4,
        );
        notifyListeners();
      }
    });
  }

  Future<void> runDiagnostics() async {
    if (_connectionState != ObdConnectionState.connected) return;
    _isScanning = true;
    _activeCodes.clear();
    notifyListeners();

    await Future.delayed(const Duration(seconds: 4));

    _activeCodes = [
      DiagnosticTroubleCode(
        code: 'P0302',
        title: 'Cylinder 2 Misfire Detected',
        system: 'Powertrain (Engine)',
        severity: DtcSeverity.critical,
        description: 'The Engine Control Module (ECM) detected that cylinder 2 is misfiring, leading to rough operation and emission failures.',
        aiAnalysis: 'MechaniQ AI suggests checking the secondary ignition system (spark plug & coil pack). Cylinder 2 shows an operational impedance variation of +18%. The fuel delivery rate is healthy, ruling out injector choking.',
        resolutionSteps: [
          'Unplug cylinder 2 coil pack and inspect for oil contamination or moisture.',
          'Swap coil pack with cylinder 1. If misfire moves to cylinder 1, replace the ignition coil.',
          'Remove spark plug and check spark gap (ideal is 0.040" for this powertrain).',
          'Ensure fuel injector harness connector is firmly seated.',
        ],
      ),
      DiagnosticTroubleCode(
        code: 'P0171',
        title: 'System Too Lean (Bank 1)',
        system: 'Fuel System',
        severity: DtcSeverity.warning,
        description: 'The oxygen sensor in Bank 1 has flagged that there is too much oxygen relative to fuel in the air-fuel ratio.',
        aiAnalysis: 'This imbalance points towards unmetered air entering the manifold past the Mass Airflow Sensor (MAF) or low fuel pressure. Dynamic load parameters indicate potential minor vacuum line leak.',
        resolutionSteps: [
          'Inspect the Mass Airflow Sensor (MAF) and clean it using specific electrical contact cleaner.',
          'Perform a smoke test or spray carburetor cleaner on vacuum hoses to isolate cracking leaks.',
          'Verify fuel pressure reading; pressure should hover between 360-400 kPa.',
        ],
      )
    ];

    _isScanning = false;
    notifyListeners();
  }

  void clearCodes() {
    _activeCodes.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _telemetryTimer?.cancel();
    super.dispose();
  }
}