import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';
import 'onboarding_screen.dart'; // लॉगिन के बाद ऑनबोर्डिंग पर जाने के लिए

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _otpSent = false;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();

  void _sendOtp() {
    if (_phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 10-digit number')),
      );
      return;
    }
    
    // TODO: यहाँ असली Firebase Auth का `verifyPhoneNumber` लॉजिक आएगा
    setState(() {
      _otpSent = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP sent successfully! (Mock)'), backgroundColor: Colors.green),
    );
  }

  void _verifyOtpAndLogin() {
    if (_otpController.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid OTP')),
      );
      return;
    }

    // TODO: यहाँ असली Firebase Auth का `signInWithCredential` लॉजिक आएगा
    
    // लॉगिन सफल होने पर Setup Vehicle (Onboarding) स्क्रीन पर भेजें
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              // Logo or Icon
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryNeonBlue, width: 2),
                  boxShadow: [
                    BoxShadow(color: AppColors.primaryNeonBlue.withOpacity(0.2), blurRadius: 20),
                  ],
                ),
                child: const Icon(Icons.security, size: 50, color: AppColors.primaryNeonBlue),
              ),
              const SizedBox(height: 30),
              
              Text(
                'SECURE LOGIN',
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Enter your registered phone number to access your MechaniQ Garage.',
                style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 40),

              // Phone Number Input
              Text("PHONE NUMBER", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, letterSpacing: 2.0),
                enabled: !_otpSent, // OTP भेजने के बाद इसे डिसेबल कर दें
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.phone_android, color: Colors.white54),
                  prefixText: "+91  ",
                  prefixStyle: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xFF14243B),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),

              // OTP Input (सिर्फ तब दिखेगा जब OTP भेजा जा चुका हो)
              if (_otpSent) ...[
                Text("ENTER OTP", style: GoogleFonts.spaceGrotesk(color: AppColors.primaryNeonBlue, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 24, letterSpacing: 10.0),
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: const Color(0xFF14243B),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 30),
              ],

              // Action Button (Send OTP / Verify OTP)
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeonBlue.withOpacity(0.1),
                    side: const BorderSide(color: AppColors.primaryNeonBlue, width: 2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _otpSent ? _verifyOtpAndLogin : _sendOtp,
                  child: Text(
                    _otpSent ? 'VERIFY & LOGIN' : 'SEND OTP',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryNeonBlue,
                      letterSpacing: 2.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
