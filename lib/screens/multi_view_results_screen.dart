import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/vehicle.dart';
import '../services/cloudflare_ai_service.dart';
import '../services/obd_service.dart';
import 'mechanic_consultation_screen.dart';

class MultiViewResultsScreen extends StatefulWidget {
  final Vehicle vehicle;
  final List<String> dtcCodes;

  const MultiViewResultsScreen({
    super.key,
    required this.vehicle,
    required this.dtcCodes,
  });

  @override
  State<MultiViewResultsScreen> createState() => _MultiViewResultsScreenState();
}

class _MultiViewResultsScreenState extends State<MultiViewResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  Map<String, dynamic> _aiResponse = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchAIResult();
  }

  void _fetchAIResult() async {
    final aiService = Provider.of<CloudflareAIService>(context, listen: false);
    final response = await aiService.queryDiagnostics(
      vehicle: widget.vehicle,
      dtcCodes: widget.dtcCodes,
      lang: 'en',
    );
    setState(() {
      _aiResponse = response;
      _isLoading = false;
    });
  }

  void _showClearDtcDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1F2833),
          title: const Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Confirm DTC Clear', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Clearing DTC codes resets the Check Engine Light and erases Freeze Frame diagnostic files. This action should only be performed after underlying components have been fixed.',
            style: TextStyle(color: Color(0xFFC5C6C7)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00FF87)),
              onPressed: () async {
                Navigator.of(context).pop();
                final obd = Provider.of<ObdService>(context, listen: false);
                await obd.clearDtcCodes();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('DTC codes successfully cleared (Service 04). Check Engine Light Reset!')),
                );
              },
              child: const Text('PROCEED RESET', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Color(0xFF00F2FE)),
              SizedBox(height: 16),
              Text('Analyzing via Secure AI Diagnostics...', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      );
    }

    final diagList = _aiResponse['diagnostics'] as List<dynamic>? ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Center'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF00F2FE),
          labelColor: const Color(0xFF00F2FE),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Rider'),
            Tab(text: 'Technical'),
            Tab(text: 'AI Analysis'),
            Tab(text: 'Cost Map'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRiderView(diagList),
          _buildMechanicView(diagList),
          _buildAiView(diagList),
          _buildCostView(diagList),
        ],
      ),
      bottomNavigationBar: _buildBottomActions(),
    );
  }

  Widget _buildRiderView(List<dynamic> diagnostics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: diagnostics.length,
        itemBuilder: (context, i) {
          final diag = diagnostics[i];
          final severityColor = diag['severity'] == 'Critical' ? Colors.red : Colors.orange;
          return Card(
            color: const Color(0xFF1F2833),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(diag['code'] as String, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF00FF87))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: severityColor.withOpacity(0.2), borderRadius: BorderRadius.circular(12)),
                        child: Text(diag['severity'] as String, style: TextStyle(color: severityColor, fontWeight: FontWeight.bold, fontSize: 12)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Rider Impact & Recommendation:', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(diag['riderExplanation'] as String, style: const TextStyle(fontSize: 15, height: 1.4)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMechanicView(List<dynamic> diagnostics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          ...diagnostics.map((diag) {
            return Card(
              color: const Color(0xFF1F2833),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Raw DTC Code: ${diag['code']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE))),
                    const SizedBox(height: 4),
                    Text('Description: ${diag['definition']}', style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          const Text('Live Sensor Graph Simulator (Service 01)', style: TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF00F2FE).withOpacity(0.3)),
            ),
            child: CustomPaint(
              painter: WaveformPainter(),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAiView(List<dynamic> diagnostics) {
    final confidence = _aiResponse['confidence'] ?? 95.0;
    final evidence = _aiResponse['evidence'] ?? "OBD-II Hex payload matching standard database engine patterns.";

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            color: const Color(0xFF1F2833),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Diagnostic Confidence', style: TextStyle(color: Color(0xFFC5C6C7))),
                  const SizedBox(height: 8),
                  Text('$confidence %', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF00FF87))),
                  const SizedBox(height: 12),
                  const Text('Analysis Evidence Match:', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                  Text(evidence, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Root Cause Decision Tree', style: TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...diagnostics.map((diag) {
            return Card(
              color: const Color(0xFF1F2833),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Possible Roots:', style: TextStyle(color: Color(0xFF00F2FE), fontWeight: FontWeight.bold)),
                    Text(diag['possibleCauses'] as String, style: const TextStyle(color: Colors.white)),
                    const Divider(color: Colors.grey, height: 24),
                    const Text('Recommended Logic Check:', style: TextStyle(color: Color(0xFF00FF87), fontWeight: FontWeight.bold)),
                    Text(diag['recommendedTest'] as String, style: const TextStyle(color: Colors.white)),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildCostView(List<dynamic> diagnostics) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView.builder(
        itemCount: diagnostics.length,
        itemBuilder: (context, i) {
          final diag = diagnostics[i];
          final double oem = diag['oemCost'] ?? 0.0;
          final double aftermarket = diag['aftermarketCost'] ?? 0.0;
          final double labor = diag['laborCost'] ?? 0.0;

          return Card(
            color: const Color(0xFF1F2833),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Price Analysis: ${diag['code']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00F2FE))),
                  const Divider(color: Colors.grey, height: 20),
                  _costRow('OEM Certified Part', '₹ $oem', Colors.white),
                  _costRow('Aftermarket Part', '₹ $aftermarket', const Color(0xFF00FF87)),
                  _costRow('Estimated Mechanics Labor', '₹ $labor', Colors.white),
                  const Divider(color: Colors.grey, height: 20),
                  _costRow('Total Estimated Cost (Aftermarket)', '₹ ${aftermarket + labor}', const Color(0xFF00F2FE), bold: true),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _costRow(String title, String cost, Color valueColor, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: const Color(0xFFC5C6C7), fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
          Text(cost, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: _showClearDtcDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CLEAR DTC', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const MechanicConsultationScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00FF87),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('CONSULT EXPERT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00F2FE)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height / 2);
    for (double i = 0; i < size.width; i += 2) {
      // Dynamic simulated sinus rhythm waveform
      double y = size.height / 2 + 30 * (0.5 * (i % 30 < 10 ? 1 : -1) + (i % 60 == 0 ? 2 : -0.2));
      path.lineTo(i, y);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}