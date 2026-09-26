import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart'; // असली Firebase पैकेज

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

  // Firebase के वेरिएबल्स
  FirebaseAuth auth = FirebaseAuth.instance;
  String _verificationId = "";

  // 1. असली फोन नंबर चेक करने और Firebase OTP भेजने का लॉजिक
  void _sendOtp() async {
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

    // Firebase Phone Auth
    await auth.verifyPhoneNumber(
      phoneNumber: "+91$phone",
      verificationCompleted: (PhoneAuthCredential credential) async {
        // अगर ऑटोमैटिक वेरीफाई हो जाए (Android में)
        await auth.signInWithCredential(credential);
        if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.message ?? 'OTP भेजने में फेल! इंटरनेट चेक करें।';
        });
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _isLoading = false;
          _isOtpSent = true;
          _verificationId = verificationId; // चाबी सेव कर ली
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("OTP आपके नंबर पर भेज दिया गया है!"),
            backgroundColor: Colors.green,
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {},
    );
  }

  // 2. असली OTP चेक करने का लॉजिक
  void _verifyOtp() async {
    String otp = _otpController.text.trim();

    if (otp.length != 6) {
      setState(() {
        _errorMessage = 'कृपया 6-अंकों का सही OTP डालें!';
      });
      return;
    }

    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });

    try {
      // Firebase से OTP मैच करना
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );
      await auth.signInWithCredential(credential);
      
      // सक्सेस होने पर डैशबोर्ड पर जाएं
      if (mounted) Navigator.pushReplacementNamed(context, '/dashboard');
      
    } catch (e) {
      setState(() {
        _isLoading = false;
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
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                    counterText: "",
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
                  onPressed: _isLoading ? null : _verifyOtp,
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
                    : Text("VERIFY & LOGIN", style: GoogleFonts.spaceGrotesk(color: Colors.cyanAccent, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
