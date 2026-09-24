import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class MultiViewResultsScreen extends StatefulWidget {
  final Map<String, dynamic>? scanData; // डैशबोर्ड से आने वाला स्कैन डेटा

  const MultiViewResultsScreen({Key? key, this.scanData}) : super(key: key);

  @override
  _MultiViewResultsScreenState createState() => _MultiViewResultsScreenState();
}

class _MultiViewResultsScreenState extends State<MultiViewResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // 4 टैब्स के लिए कंट्रोलर
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
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF14243B),
        elevation: 0,
        title: Text(
          'DIAGNOSTIC REPORT',
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.primaryNeonBlue),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: AppColors.primaryNeonBlue,
          indicatorWeight: 4,
          labelColor: AppColors.primaryNeonBlue,
          unselectedLabelColor: Colors.white54,
          labelStyle: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.person), text: "Rider"),
            Tab(icon: Icon(Icons.build), text: "Mechanic"),
            Tab(icon: Icon(Icons.auto_awesome), text: "AI Root Cause"),
            Tab(icon: Icon(Icons.currency_rupee), text: "Cost"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRiderView(),
          _buildMechanicView(),
          _buildAIView(),
          _buildCostView(),
        ],
      ),
    );
  }

  // ================= TAB 1: RIDER VIEW =================
  Widget _buildRiderView() {
    return _buildTabContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orangeAccent),
          const SizedBox(height: 20),
          Text("Engine Misfire Detected", style: GoogleFonts.orbitron(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          Text(
            "आपकी गाड़ी के इंजन में मामूली समस्या है।",
            style: GoogleFonts.notoSans(color: Colors.white70, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.orangeAccent.withOpacity(0.1),
              border: Border.all(color: Colors.orangeAccent),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.orangeAccent),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Can I ride?: Yes, but keep speed under 40 km/h and visit garage soon.",
                    style: GoogleFonts.spaceGrotesk(color: Colors.orangeAccent),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= TAB 2: MECHANIC VIEW =================
  Widget _buildMechanicView() {
    return _buildTabContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("RAW DTC CODES", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildInfoRow("P0300", "Random/Multiple Cylinder Misfire Detected", Colors.redAccent),
          _buildInfoRow("P0171", "System Too Lean (Bank 1)", Colors.orangeAccent),
          const Divider(color: Colors.white24, height: 40),
          Text("FREEZE FRAME DATA", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          _buildInfoRow("Engine RPM", "3100 rev/min", Colors.white70),
          _buildInfoRow("Coolant Temp", "95 °C", Colors.white70),
          _buildInfoRow("Fuel Pressure", "42.0 kPa", Colors.white70),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.delete_forever, color: Colors.white),
              label: const Text("CLEAR DTC CODES (Service 04)"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade900),
            ),
          )
        ],
      ),
    );
  }

  // ================= TAB 3: AI VIEW =================
  Widget _buildAIView() {
    return _buildTabContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: AppColors.primaryNeonBlue),
              const SizedBox(width: 10),
              Text("AI DIAGNOSIS", style: GoogleFonts.orbitron(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            "Based on the combination of P0300 and P0171, the AI has determined with 89% confidence that the issue is a vacuum leak causing a lean mixture, leading to the misfire.",
            style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 20),
          Text("NEXT TESTS TO PERFORM:", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          _buildChecklistItem("Check intake manifold gasket for leaks"),
          _buildChecklistItem("Inspect vacuum hoses for cracks"),
          _buildChecklistItem("Check mass airflow (MAF) sensor"),
        ],
      ),
    );
  }

  // ================= TAB 4: COST VIEW =================
  Widget _buildCostView() {
    return _buildTabContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ESTIMATED REPAIR COST", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          _buildCostRow("Vacuum Hose Replacement", "₹450"),
          _buildCostRow("Labour Charges", "₹300"),
          const Divider(color: Colors.white24, height: 30),
          _buildCostRow("Total Estimated Cost", "₹750", isTotal: true),
          const SizedBox(height: 40),
          Text("Note: Prices are estimates based on standard aftermarket parts in India.", style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  // ================= HELPER WIDGETS =================
  Widget _buildTabContainer({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: const Color(0xFF14243B),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white10),
        ),
        child: child,
      ),
    );
  }

  Widget _buildInfoRow(String title, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: GoogleFonts.spaceGrotesk(color: valueColor), textAlign: TextAlign.right)),
        ],
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.spaceGrotesk(color: Colors.white))),
        ],
      ),
    );
  }

  Widget _buildCostRow(String item, String price, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(item, style: GoogleFonts.spaceGrotesk(color: isTotal ? Colors.white : Colors.white70, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
          Text(price, style: GoogleFonts.spaceGrotesk(color: isTotal ? AppColors.primaryNeonBlue : Colors.white, fontSize: isTotal ? 18 : 14, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
