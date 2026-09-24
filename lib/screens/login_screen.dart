import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOtpSent = false;
  bool _isLoading = false;

  void _triggerLoginProcess() async {
    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isLoading = false;
      if (!_isOtpSent) {
        _isOtpSent = true;
      } else {
        Navigator.pushReplacementNamed(context, '/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cyberpunk Grid Pattern / Gradient Backing
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0A0B10), Color(0xFF121424)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00E5FF).withOpacity(0.08),
                blurRadius: 100,
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF00FFCC).withOpacity(0.06),
                blurRadius: 120,
              ),
            ),
          ),
          // Content Layout
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Brand Identity Icon
                    Center(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF00FFCC), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF00FFCC).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.settings_suggest_sharp,
                          color: Color(0xFF00FFCC),
                          size: 55,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Title
                    Text(
                      'MECHANIQ',
                      textAlign: Alignment.center,
                      style: GoogleFonts.orbitron(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 4,
                        color: Colors.white,
                        shadows: [
                          const Shadow(
                            color: Color(0xFF00E5FF),
                            offset: Offset(0, 0),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'SECURE QUANTUM ACCESS',
                      textAlign: Alignment.center,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 14,
                        letterSpacing: 2,
                        color: const Color(0xFF00FFCC),
                      ),
                    ),
                    const SizedBox(height: 50),
                    
                    // Main Terminal Container
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF121420).withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFF1F2444), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedCrossFade(
                            firstChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ENTER MOBILE OPERATOR NUMBER',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 12,
                                    color: const Color(0xFF00E5FF),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  style: GoogleFonts.shareTechMono(fontSize: 18, color: Colors.white),
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.phone_android, color: Color(0xFF00FFCC)),
                                    hintText: "+1 234 567 8900",
                                  ),
                                ),
                              ],
                            ),
                            secondChild: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'ENTER VERIFICATION SECURE CODE',
                                  style: GoogleFonts.shareTechMono(
                                    fontSize: 12,
                                    color: const Color(0xFF00FFCC),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                TextField(
                                  controller: _otpController,
                                  keyboardType: TextInputType.number,
                                  style: GoogleFonts.shareTechMono(fontSize: 18, color: Colors.white, letterSpacing: 8),
                                  textAlign: TextAlign.center,
                                  decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF00E5FF)),
                                    hintText: "******",
                                  ),
                                ),
                              ],
                            ),
                            crossFadeState: _isOtpSent ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                            duration: const Duration(milliseconds: 300),
                          ),
                          const SizedBox(height: 24),
                          
                          // Custom Neon Button
                          SizedBox(
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _triggerLoginProcess,
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0A0B10)),
                                    )
                                  : Text(
                                      _isOtpSent ? 'DECRYPT & LOG IN' : 'SEND SECURITY OTP',
                                      style: const TextStyle(fontSize: 14),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Footer details
                    Text(
                      'By initializing this application, you authorize full diagnostics telemetry protocols.',
                      textAlign: Alignment.center,
                      style: GoogleFonts.shareTechMono(
                        fontSize: 10,
                        color: Colors.white30,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}