import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async'; // Payment Loading के लिए

class GarageScreen extends StatefulWidget {
  @override
  _GarageScreenState createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  // आपका पुराना सुरक्षित डेटाबेस (कोई छेड़छाड़ नहीं)
  List<Map<String, dynamic>> _mechanics = [
    {"name": "Rajesh Auto Works", "specialty": "BS6 & Engine Specialist", "rating": "4.9", "isOnline": true, "fee": "99"},
    {"name": "Sharma Diagnostics", "specialty": "Wiring & ECU Specialist", "rating": "4.7", "isOnline": true, "fee": "149"},
  ];

  bool _isRegistering = false; 

  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  // आपका पुराना प्रोफाइल सेव करने का लॉजिक (कोई छेड़छाड़ नहीं)
  void _saveMechanicProfile() {
    if (_shopNameController.text.isEmpty || _expertiseController.text.isEmpty || _feeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("कृपया सभी डिटेल्स भरें!"), backgroundColor: Colors.redAccent));
      return;
    }

    setState(() {
      _mechanics.add({
        "name": _shopNameController.text.trim(),
        "specialty": _expertiseController.text.trim(),
        "rating": "5.0", 
        "isOnline": true,
        "fee": _feeController.text.trim(),
      });
      _isRegistering = false; 
    });

    _shopNameController.clear();
    _expertiseController.clear();
    _feeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("आपका मैकेनिक प्रोफाइल लाइव हो गया है!"), backgroundColor: Colors.green));
  }

  // 🚀 नया फीचर: UPI Payment Simulator (Zero-Risk Test Mode)
  void _startTestPayment(String mechanicName, String amount) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Color(0xFF161B22),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return PaymentProcessorUI(mechanicName: mechanicName, amount: amount);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), // MechaniQ Theme
      appBar: AppBar(
        backgroundColor: Color(0xFF161B22),
        title: Text(
          _isRegistering ? "CREATE PROFILE" : "EXPERT GARAGE",
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              setState(() {
                _isRegistering = !_isRegistering;
              });
            },
            icon: Icon(_isRegistering ? Icons.list : Icons.build_circle, color: Colors.cyanAccent),
            label: Text(
              _isRegistering ? "VIEW LIST" : "BECOME EXPERT",
              style: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
      body: _isRegistering ? _buildRegistrationForm() : _buildMechanicsList(),
    );
  }

  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.storefront, size: 60, color: Colors.cyanAccent),
          SizedBox(height: 20),
          Text("अपना गैरेज रजिस्टर करें", textAlign: TextAlign.center, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 30),
          _buildTextField(_shopNameController, "गैरेज का नाम (e.g., Ram Auto Works)", Icons.home_repair_service),
          SizedBox(height: 16),
          _buildTextField(_expertiseController, "आपकी एक्सपर्टीज (e.g., EV, BS6, Wiring)", Icons.engineering),
          SizedBox(height: 16),
          _buildTextField(_feeController, "कंसल्टेशन फीस (₹)", Icons.currency_rupee, isNumber: true),
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveMechanicProfile,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent, padding: EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text("SAVE & GO LIVE", style: GoogleFonts.orbitron(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildMechanicsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _mechanics.length,
      itemBuilder: (context, index) {
        final mech = _mechanics[index];
        return Card(
          color: Color(0xFF161B22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.white12)),
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.cyanAccent)),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(mech["name"], style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(mech["specialty"], style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(children: [Icon(Icons.star, color: Colors.amber, size: 16), SizedBox(width: 4), Text(mech["rating"], style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold))]),
                        SizedBox(height: 4),
                        Row(children: [CircleAvatar(radius: 4, backgroundColor: mech["isOnline"] ? Colors.greenAccent : Colors.redAccent), SizedBox(width: 4), Text(mech["isOnline"] ? "Online" : "Busy", style: GoogleFonts.spaceGrotesk(color: mech["isOnline"] ? Colors.greenAccent : Colors.redAccent, fontSize: 10))]),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.white12),
                
                // 🚀 नया फीचर: Payment Button UI
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Live Consultation", style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14)),
                    Text("₹${mech["fee"]}", style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: mech["isOnline"] ? () => _startTestPayment(mech["name"], mech["fee"]) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: mech["isOnline"] ? Colors.cyanAccent : Colors.white24)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      "PAY ₹${mech["fee"]} & CONNECT",
                      style: GoogleFonts.spaceGrotesk(color: mech["isOnline"] ? Colors.cyanAccent : Colors.white54, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isNumber = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: GoogleFonts.spaceGrotesk(color: Colors.white),
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: GoogleFonts.spaceGrotesk(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.cyanAccent),
        enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white24), borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent), borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// 🚀 नया फीचर: Payment Processing का असली जैसा दिखने वाला UI 
class PaymentProcessorUI extends StatefulWidget {
  final String mechanicName;
  final String amount;
  PaymentProcessorUI({required this.mechanicName, required this.amount});

  @override
  _PaymentProcessorUIState createState() => _PaymentProcessorUIState();
}

class _PaymentProcessorUIState extends State<PaymentProcessorUI> {
  String _statusMessage = "Starting Secure UPI Payment...";
  IconData _statusIcon = Icons.lock_outline;
  Color _statusColor = Colors.cyanAccent;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _processFakePayment();
  }

  void _processFakePayment() async {
    // 1. Connection Load
    await Future.delayed(Duration(seconds: 2));
    if(mounted) setState(() { _statusMessage = "Waiting for UPI App (Test Mode)..."; });
    
    // 2. Processing
    await Future.delayed(Duration(seconds: 2));
    if(mounted) setState(() { _statusMessage = "Processing ₹${widget.amount}..."; });

    // 3. Success
    await Future.delayed(Duration(seconds: 2));
    if(mounted) setState(() {
      _statusMessage = "Payment Successful!";
      _statusIcon = Icons.check_circle;
      _statusColor = Colors.greenAccent;
      _isSuccess = true;
    });

    // 4. Close Popup and Connect
    await Future.delayed(Duration(seconds: 2));
    if(mounted) {
      Navigator.pop(context); // Close BottomSheet
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connecting to ${widget.mechanicName}..."), backgroundColor: Colors.green)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(30),
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isSuccess 
              ? Icon(_statusIcon, size: 80, color: _statusColor)
              : CircularProgressIndicator(color: _statusColor, strokeWidth: 4),
          SizedBox(height: 30),
          Text(
            "₹${widget.amount}",
            style: GoogleFonts.orbitron(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          Text(
            _statusMessage,
            style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
