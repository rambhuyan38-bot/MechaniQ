import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/vehicle_model.dart';
import 'services/auth_service.dart';
import 'routes/app_routes.dart';

// Complete Core State Management Classes for MultiProvider registration

// 1. Auth Provider State
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  dynamic _user; // Using dynamic here to safely stub or wrap around Firebase User configurations

  AuthProvider() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  bool get isAuthenticated => _user != null;
  dynamic get user => _user;

  Future<void> signIn(String email, String password) async {
    await _authService.signInWithEmailAndPassword(email, password);
    notifyListeners();
  }

  Future<void> signUp(String email, String password) async {
    await _authService.signUpWithEmailAndPassword(email, password);
    notifyListeners();
  }

  Future<void> signOut() async {
    await _authService.signOut();
    notifyListeners();
  }
}

// 2. OBD Service State Provider
class ObdProvider extends ChangeNotifier {
  bool _isConnected = false;
  String _connectionStatus = 'Disconnected';
  final List<String> _diagnosticCodes = [];

  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;
  List<String> get diagnosticCodes => _diagnosticCodes;

  void connectOBD() {
    _connectionStatus = 'Searching...';
    notifyListeners();
    
    // Simulate Bluetooth latency
    Future.delayed(const Duration(seconds: 2), () {
      _isConnected = true;
      _connectionStatus = 'Connected via Bluetooth';
      _diagnosticCodes.addAll(['P0300', 'P0171']); // Sample DTCs
      notifyListeners();
    });
  }

  void disconnectOBD() {
    _isConnected = false;
    _connectionStatus = 'Disconnected';
    _diagnosticCodes.clear();
    notifyListeners();
  }
}

// 3. Vehicle Service State Provider
class VehicleProvider extends ChangeNotifier {
  final List<VehicleModel> _vehicles = [];
  VehicleModel? _selectedVehicle;

  List<VehicleModel> get vehicles => _vehicles;
  VehicleModel? get selectedVehicle => _selectedVehicle;

  void addVehicle(VehicleModel vehicle) {
    _vehicles.add(vehicle);
    if (_selectedVehicle == null) {
      _selectedVehicle = vehicle;
    }
    notifyListeners();
  }

  void selectVehicle(VehicleModel vehicle) {
    _selectedVehicle = vehicle;
    notifyListeners();
  }

  void updateMileage(String id, double newMileage) {
    final index = _vehicles.indexWhere((v) => v.id == id);
    if (index != -1) {
      _vehicles[index] = _vehicles[index].copyWith(mileage: newMileage);
      if (_selectedVehicle?.id == id) {
        _selectedVehicle = _vehicles[index];
      }
      notifyListeners();
    }
  }
}

// 4. AI Diagnostics Provider
class AiProvider extends ChangeNotifier {
  bool _isAnalyzing = false;
  String _analysisReport = '';

  bool get isAnalyzing => _isAnalyzing;
  String get analysisReport => _analysisReport;

  Future<void> analyzeTroubleCodes(List<String> codes) async {
    if (codes.isEmpty) return;
    _isAnalyzing = true;
    _analysisReport = '';
    notifyListeners();

    // Mock AI Remote Processing delay
    await Future.delayed(const Duration(seconds: 3));

    _analysisReport = 'MechaniQ AI Diagnostic Summary:\n\n'
        'Detected Engine Misfire (P0300) and System Too Lean (P0171).\n'
        'Primary Cause: Mass Airflow (MAF) sensor contamination or vacuum leak.\n'
        'Severity: Moderate. Continuous operation could cause catalyst failure.\n'
        'Recommended Fix: Clean or swap MAF sensor, inspect vacuum lines.';
        
    _isAnalyzing = false;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // To use complete native Firebase, ensure Firebase.initializeApp() is called here when google-services.json is configured.
  // We have structured code architecture to operate gracefully.
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ObdProvider()),
        ChangeNotifierProvider(create: (_) => VehicleProvider()),
        ChangeNotifierProvider(create: (_) => AiProvider()),
      ],
      child: const MechaniQApp(),
    ),
  );
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechaniQ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orangeAccent,
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Colors.orangeAccent,
          secondary: Colors.blueAccent,
          surface: Color(0xFF1E1E1E),
        ),
      ),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}