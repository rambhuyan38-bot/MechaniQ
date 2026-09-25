import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Numbers only के लिए जरूरी
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  
  bool _isOtpSent = false;
  bool _isLoading = false;
  String _errorMessage = '';

  // 1. असली फोन नंबर चेक करने का लॉजिक
  void _sendOtp() {
    String phone = _phoneController.text.trim();
    
    if (phone.length != 10) {
      setState(() {
        _errorMessage = 'कृपया सही 10-अंकों का मोबाइल नंबर डालें!';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    // यहाँ हम आगे Firebase जोड़ेंगे। अभी के लिए असली जैसी फीलिंग देने के लिए 2 सेकंड की लोडिंग लगाई है।
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
        _isOtpSent = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("OTP आपके नंबर पर भेज दिया गया है!"),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  // 2. असली OTP चेक करने का लॉजिक
  void _verifyOtp() {
    String otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'कृपया 6-अंकों का सही OTP डालें!';
      });
      return;
    }

    // जब तक Firebase कनेक्ट नहीं होता, टेस्टिंग के लिए असली OTP '123456' रखा है
    // इसके अलावा कोई भी OTP डालेंगे तो 'Invalid OTP' बताएगा!
    if (otp == '123456') {
      Navigator.pushReplacementNamed(context, '/dashboard'); // या आपकी होम स्क्रीन
    } else {
      setState(() {
        _errorMessage = 'गलत OTP! कृपया दोबारा प्रयास करें।';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), // MechaniQ Dark Theme
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(Icons.shield, size: 60, color: Colors.cyanAccent),
              SizedBox(height: 20),
              Text(
                "SECURE LOGIN",
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 40),

              // एरर मैसेज दिखाने की जगह
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    _errorMessage,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.spaceGrotesk(color: Colors.redAccent, fontSize: 14),
                  ),
                ),

              if (!_isOtpSent) ...[
                // PHONE NUMBER FIELD (Strict 10 Digits)
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone, // सिर्फ नंबर वाला कीबोर्ड खुलेगा
                  maxLength: 10, // 10 से ज्यादा टाइप नहीं होगा
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly], // ABCD टाइप ही नहीं होगा
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18),
                  decoration: InputDecoration(
                    labelText: "PHONE NUMBER",
                    labelStyle: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent),
                    prefixText: "+91  ",
                    prefixStyle: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "", // maxLength के नीचे का नंबर छुपाने के लिए
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _sendOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.cyanAccent),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                    ? CircularProgressIndicator(color: Colors.cyanAccent)
                    : Text("SEND OTP", style: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ] else ...[
                // OTP FIELD (Strict 6 Digits)
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, letterSpacing: 10.0),
                  decoration: InputDecoration(
                    labelText: "ENTER OTP",
                    labelStyle: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyanAccent),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    counterText: "",
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _verifyOtp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.cyanAccent),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text("VERIFY & LOGIN", style: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
