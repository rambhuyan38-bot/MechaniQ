import 'package:flutter/material.dart';
import 'services/cloudflare_ai_service.dart';

void main() {
  runApp(const MechaniQApp());
}

class MechaniQApp extends StatelessWidget {
  const MechaniQApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MechaniQ AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CloudflareAIService _aiService = CloudflareAIService();
  String _result = 'Press the button below to simulate OBD Scan & AI Analysis';
  bool _isLoading = false;

  void _analyzeOBD() async {
    setState(() {
      _isLoading = true;
      _result = 'Sending secure OBD payload to MechaniQ AI Backend...';
    });

    try {
      final Map<String, dynamic> mockOBDData = {
        'dtc_code': 'P0302',
        'engine_rpm': '3200',
        'coolant_temp': '98 C',
        'short_term_fuel_trim': '+12%',
        'long_term_fuel_trim': '+8%',
        'description': 'Cylinder 2 Misfire Detected'
      };

      final response = await _aiService.analyzeFault(mockOBDData);
      setState(() {
        _result = 'AI Analysis Report:\n\n${response.toString()}';
      });
    } catch (e) {
      setState(() {
        _result = 'Error during diagnostics: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MechaniQ AI Diagnostics'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Secure API Endpoint:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade200),
                    ),
                    const Text(
                      'https://rough-block-3dd9.rambhuyan23.workers.dev/analyze',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Active Security Header:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade200),
                    ),
                    const Text(
                      "X-App-Secret: MechaniQ_Secure_Key_2026_!@#",
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Card(
                color: Colors.grey.shade900,
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        color: Colors.greenAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _analyzeOBD,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.security),
              label: Text(_isLoading ? 'Analyzing...' : 'Run Secured Diagnostics Scan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}