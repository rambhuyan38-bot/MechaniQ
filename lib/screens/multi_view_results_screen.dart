import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class MultiViewResultsScreen extends StatefulWidget {
  const MultiViewResultsScreen({super.key});

  @override
  State<MultiViewResultsScreen> createState() => _MultiViewResultsScreenState();
}

class _MultiViewResultsScreenState extends State<MultiViewResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151D2A),
        elevation: 0,
        title: const Text(
          'DIAGNOSTIC REPORT',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: const Color(0xFF00FFCC),
          labelColor: const Color(0xFF00FFCC),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'RIDER VIEW'),
            Tab(text: 'MECHANIC VIEW'),
            Tab(text: 'AI VIEW'),
            Tab(text: 'COST VIEW'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRiderTab(),
          _buildMechanicTab(),
          _buildAITab(),
          _buildCostTab(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showClearDTCDialog(context),
        backgroundColor: const Color(0xFFFF3366),
        icon: const Icon(Icons.delete_forever, color: Colors.white),
        label: const Text(
          'Clear DTC (Premium)',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildRiderTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFB300).withOpacity(0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Color(0xFFFFB300), size: 40),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Safe to ride but check emissions',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Detected minor combustion variations. The exhaust emission limits may be slightly exceeded.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Actionable Guidance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 12),
          _buildGuidanceItem(Icons.check_circle_outline, 'Keep speeds under 80 km/h to optimize combustion.'),
          _buildGuidanceItem(Icons.check_circle_outline, 'Ensure engine fuel filler cap is tightened completely.'),
          _buildGuidanceItem(Icons.check_circle_outline, 'Schedule a checkup within the next 200 km.'),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF00FFCC), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildMechanicTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Raw Diagnostic Codes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF151D2A),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.between,
                  children: [
                    Text('DTC P0301', style: TextStyle(fontFamily: 'Courier', fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFFFF3366))),
                    Text('Active / Confirmed', style: TextStyle(color: Color(0xFFFF3366), fontSize: 12)),
                  ],
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Cylinder 1 Misfire Detected', style: TextStyle(color: Colors.white, fontSize: 14)),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Freeze Frame Data',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 12),
          Table(
            border: TableBorder.all(color: Colors.white.withOpacity(0.05)),
            children: const [
              TableRow(children: [
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Engine Speed (RPM)', style: TextStyle(color: Colors.grey)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('3,250 rpm', style: TextStyle(color: Colors.white)))),
              ]),
              TableRow(children: [
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Calculated Load', style: TextStyle(color: Colors.grey)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('72.4 %', style: TextStyle(color: Colors.white)))),
              ]),
              TableRow(children: [
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Coolant Temperature', style: TextStyle(color: Colors.grey)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('96 °C', style: TextStyle(color: Colors.white)))),
              ]),
              TableRow(children: [
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('Fuel Pressure', style: TextStyle(color: Colors.grey)))),
                TableCell(child: Padding(padding: EdgeInsets.all(8.0), child: Text('315 kPa', style: TextStyle(color: Colors.white)))),
              ]),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Live Sensor Waveform',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: const FlTitlesData(show: false),
                borderData: FlBorderData(show: true, border: Border.all(color: Colors.white.withOpacity(0.1))),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 1.2),
                      FlSpot(1, 1.5),
                      FlSpot(2, 0.8),
                      FlSpot(3, 2.4),
                      FlSpot(4, 1.3),
                      FlSpot(5, 1.9),
                      FlSpot(6, 1.1),
                    ],
                    isCurved: true,
                    color: const Color(0xFF00FFCC),
                    barWidth: 3,
                    belowBarData: BarAreaData(show: true, color: const Color(0xFF00FFCC).withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAITab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI Confidence Level',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, py: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFCC).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '94% MATCH',
                  style: TextStyle(color: Color(0xFF00FFCC), fontWeight: FontWeight.bold, fontSize: 12),
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          const LinearProgressIndicator(
            value: 0.94,
            backgroundColor: Color(0xFF151D2A),
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 24),
          const Text(
            'Root Cause Analysis',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 8),
          const Text(
            'High-voltage discharge mismatch detected specifically in Cylinder 1. It points to a degraded ignition coil insulation or a fouled terminal tip.',
            style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
          ),
          const SizedBox(height: 24),
          const Text(
            'Decision Logic Path',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF00FFCC)),
          ),
          const SizedBox(height: 12),
          _buildDecisionNode('Signal mismatch: Cylinder 1 Ionization level abnormal'),
          _buildDecisionNode('Evaluation logic: Voltage leak pattern recognized'),
          _buildDecisionNode('Diagnosis result: Spark Plug Failure imminent'),
        ],
      ),
    );
  }

  Widget _buildDecisionNode(String step) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          const Icon(Icons.subdirectory_arrow_right, color: Color(0xFF00FFCC), size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(step, style: const TextStyle(fontSize: 13, color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildCostTab() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimated Spare Parts',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildCostItem('OEM Spark Plug (High Durability)', '₹1,450'),
          _buildCostItem('Aftermarket Premium Plug', '₹850'),
          const Divider(color: Colors.white10),
          const SizedBox(height: 12),
          const Text(
            'Labor Fee Breakdown',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          _buildCostItem('Standard Mechanic Service', '₹450 - ₹600'),
          _buildCostItem('Authorized Workshop Service', '₹900 - ₹1,200'),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF00FFCC).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF00FFCC).withOpacity(0.2)),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total Estimated Budget', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('₹1,300 - ₹2,650', style: TextStyle(fontWeight: FontWeight.black, fontSize: 18, color: Color(0xFF00FFCC))),
              ],
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildCostItem(String item, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          Text(price, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showClearDTCDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF151D2A),
          title: const Text('Clear DTCs', style: TextStyle(color: Colors.white)),
          content: const Text(
            'This command resets active ECU diagnostics. Ensure vehicle ignition is ON and engine is OFF.',
            style: TextStyle(color: Colors.grey),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ECU Reset command dispatched successfully!'),
                    backgroundColor: Color(0xFF00FFCC),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF3366)),
              child: const Text('CLEAR NOW', style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
}