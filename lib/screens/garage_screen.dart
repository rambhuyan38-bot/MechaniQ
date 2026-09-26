import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GarageScreen extends StatefulWidget {
  @override
  _GarageScreenState createState() => _GarageScreenState();
}

class _GarageScreenState extends State<GarageScreen> {
  // यह हमारा लाइव डेटाबेस (List) है। Firebase लगने पर डेटा सीधा सर्वर से आएगा।
  List<Map<String, dynamic>> _mechanics = [
    {"name": "Rajesh Auto Works", "specialty": "BS6 & Engine Specialist", "rating": "4.9", "isOnline": true, "fee": "₹99"},
    {"name": "Sharma Diagnostics", "specialty": "Wiring & ECU Specialist", "rating": "4.7", "isOnline": true, "fee": "₹149"},
  ];

  bool _isRegistering = false; // यह तय करेगा कि लिस्ट दिखानी है या रजिस्ट्रेशन फॉर्म

  // फॉर्म के कंट्रोलर्स
  final TextEditingController _shopNameController = TextEditingController();
  final TextEditingController _expertiseController = TextEditingController();
  final TextEditingController _feeController = TextEditingController();

  // नया मैकेनिक प्रोफाइल सेव करने का लॉजिक
  void _saveMechanicProfile() {
    if (_shopNameController.text.isEmpty || _expertiseController.text.isEmpty || _feeController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("कृपया सभी डिटेल्स भरें!"), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      // नया प्रोफाइल हमारे डेटाबेस (लिस्ट) में जोड़ रहे हैं
      _mechanics.add({
        "name": _shopNameController.text.trim(),
        "specialty": _expertiseController.text.trim(),
        "rating": "5.0", // नए मैकेनिक को डिफ़ॉल्ट 5 स्टार
        "isOnline": true,
        "fee": "₹${_feeController.text.trim()}",
      });
      _isRegistering = false; // वापस लिस्ट वाले पेज पर भेज रहे हैं
    });

    _shopNameController.clear();
    _expertiseController.clear();
    _feeController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("आपका मैकेनिक प्रोफाइल लाइव हो गया है!"), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), // MechaniQ Dark Theme
      appBar: AppBar(
        backgroundColor: Color(0xFF161B22),
        title: Text(
          _isRegistering ? "CREATE PROFILE" : "EXPERT GARAGE",
          style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          // यह बटन कस्टमर और मैकेनिक व्यू के बीच स्विच करेगा
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

  // 1. मैकेनिक का प्रोफाइल बनाने वाला असली फॉर्म
  Widget _buildRegistrationForm() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(Icons.storefront, size: 60, color: Colors.cyanAccent),
          SizedBox(height: 20),
          Text(
            "अपना गैरेज रजिस्टर करें",
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 30),
          
          _buildTextField(_shopNameController, "गैरेज का नाम (e.g., Ram Auto Works)", Icons.home_repair_service),
          SizedBox(height: 16),
          _buildTextField(_expertiseController, "आपकी एक्सपर्टीज (e.g., EV, BS6, Wiring)", Icons.engineering),
          SizedBox(height: 16),
          _buildTextField(_feeController, "कंसल्टेशन फीस (₹)", Icons.currency_rupee, isNumber: true),
          
          SizedBox(height: 40),
          ElevatedButton(
            onPressed: _saveMechanicProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(
              "SAVE & GO LIVE",
              style: GoogleFonts.orbitron(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // 2. लाइव मैकेनिक्स की लिस्ट दिखाने वाला UI
  Widget _buildMechanicsList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _mechanics.length,
      itemBuilder: (context, index) {
        final mech = _mechanics[index];
        return Card(
          color: Color(0xFF161B22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.white12),
          ),
          margin: EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Icon(Icons.person, color: Colors.cyanAccent),
                    ),
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
                        Row(
                          children: [
                            Icon(Icons.star, color: Colors.amber, size: 16),
                            SizedBox(width: 4),
                            Text(mech["rating"], style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            CircleAvatar(radius: 4, backgroundColor: mech["isOnline"] ? Colors.greenAccent : Colors.redAccent),
                            SizedBox(width: 4),
                            Text(mech["isOnline"] ? "Online" : "Busy", style: GoogleFonts.spaceGrotesk(color: mech["isOnline"] ? Colors.greenAccent : Colors.redAccent, fontSize: 10)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Divider(color: Colors.white12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Live Consultation", style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 14)),
                    Text(mech["fee"], style: GoogleFonts.orbitron(color: Colors.cyanAccent, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // टेक्स्ट फील्ड बनाने का छोटा फंक्शन
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
