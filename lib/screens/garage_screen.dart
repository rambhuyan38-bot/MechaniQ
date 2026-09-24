import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class GarageScreen extends StatefulWidget {
  const GarageScreen({Key? key}) : super(key: key);

  @override
  _GarageScreenState createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  // Mock Payment (नकली पेमेंट) का एनीमेशन दिखाने वाला फंक्शन
  void _showMockPaymentGateway(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const MockPaymentSheet();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'EXPERT GARAGE',
          style: GoogleFonts.orbitron(
            color: AppColors.primaryNeonBlue,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF14243B), Color(0xFF0D0D0D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: AppColors.primaryNeonBlue.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryNeonBlue.withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.support_agent, color: AppColors.primaryNeonBlue, size: 40),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          "Talk to a Certified Mechanic",
                          style: GoogleFonts.orbitron(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Text(
                    "Stuck somewhere? Share your MechaniQ diagnostic report directly with an expert and get a live solution within 5 minutes.",
                    style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 13, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            Text("AVAILABLE EXPERTS", style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
            const SizedBox(height: 15),

            // Mechanic List
            _buildMechanicCard("Rajesh Auto Works", "BS6 & Engine Specialist", "4.9", true),
            _buildMechanicCard("EV Care Motors", "Electric Vehicle Expert", "4.8", false),
            _buildMechanicCard("Sharma Diagnostics", "Wiring & ECU Specialist", "4.7", true),

            const SizedBox(height: 30),

            // Pricing & Booking Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF14243B),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("5-Min Live Consultation", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16)),
                      Text("₹99", style: GoogleFonts.orbitron(color: AppColors.primaryNeonBlue, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryNeonBlue.withOpacity(0.1),
                        side: const BorderSide(color: AppColors.primaryNeonBlue, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: () => _showMockPaymentGateway(context),
                      child: Text(
                        'PAY ₹99 & CONNECT',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryNeonBlue,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Mechanic Card UI
  Widget _buildMechanicCard(String name, String specialty, String rating, bool isOnline) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF14243B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white10,
            radius: 25,
            child: Icon(Icons.person, color: isOnline ? Colors.white : Colors.white54),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(specialty, style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber, size: 16),
                  const SizedBox(width: 4),
                  Text(rating, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: isOnline ? Colors.greenAccent : Colors.redAccent, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(isOnline ? "Online" : "Busy", style: GoogleFonts.spaceGrotesk(color: isOnline ? Colors.greenAccent : Colors.redAccent, fontSize: 10)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= PAYMENT GATEWAY (MOCK UI) =================
class MockPaymentSheet extends StatefulWidget {
  const MockPaymentSheet({Key? key}) : super(key: key);

  @override
  _MockPaymentSheetState createState() => _MockPaymentSheetState();
}

class _MockPaymentSheetState extends State<MockPaymentSheet> {
  bool isProcessing = true;
  bool isSuccess = false;

  @override
  void initState() {
    super.initState();
    _processPayment();
  }

  void _processPayment() async {
    // 3 सेकंड तक लोडिंग दिखाएगा (UPI/Gateway की तरह)
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        isProcessing = false;
        isSuccess = true;
      });
    }
    // सक्सेस होने के 2 सेकंड बाद पॉप-अप बंद हो जाएगा
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      Navigator.pop(context); // पॉप-अप बंद करो
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Connecting to Mechanic...'), backgroundColor: Colors.green),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),
      height: 300,
      decoration: const BoxDecoration(
        color: Color(0xFF14243B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isProcessing) ...[
              const CircularProgressIndicator(color: AppColors.primaryNeonBlue),
              const SizedBox(height: 20),
              Text("Processing Payment via UPI...", style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 16)),
              const SizedBox(height: 10),
              Text("Please do not close this screen", style: GoogleFonts.spaceGrotesk(color: Colors.white38, fontSize: 12)),
            ] else if (isSuccess) ...[
              const Icon(Icons.check_circle, color: Colors.greenAccent, size: 80),
              const SizedBox(height: 20),
              Text("Payment Successful!", style: GoogleFonts.orbitron(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text("Amount Paid: ₹99", style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16)),
            ],
          ],
        ),
      ),
    );
  }
}
