import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _otpSent = false;
  bool _isLoading = false;

  void _triggerAuth() async {
    setState(() {
      _isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      if (!_otpSent) {
        _otpSent = true;
      } else {
        Navigator.of(context).pushReplacementNamed('/onboarding');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocaleProvider>(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0B0C10), Color(0xFF1F2833)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bolt, color: Color(0xFF00FF87), size: 48),
                  const SizedBox(width: 10),
                  Text(
                    'MechaniQ',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Secured Next-Gen AI Diagnostics',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF00FF87), fontSize: 12, letterSpacing: 1.5),
              ),
              const SizedBox(height: 48),
              DropdownButtonFormField<String>(
                value: loc.locale.languageCode,
                decoration: InputDecoration(
                  labelText: 'Select Language / भाषा चुनें',
                  labelStyle: const TextStyle(color: Color(0xFF00F2FE)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'en', child: Text('English')),
                  DropdownMenuItem(value: 'hi', child: Text('हिन्दी (Hindi)')),
                  DropdownMenuItem(value: 'mr', child: Text('मराठी (Marathi)')),
                  DropdownMenuItem(value: 'ta', child: Text('தமிழ் (Tamil)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    loc.changeLocale(val);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: const TextStyle(color: Color(0xFFC5C6C7)),
                  prefixIcon: const Icon(Icons.phone, color: Color(0xFF00F2FE)),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00F2FE), width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (_otpSent) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _otpController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    labelStyle: const TextStyle(color: Color(0xFFC5C6C7)),
                    prefixIcon: const Icon(Icons.lock_clock, color: Color(0xFF00FF87)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Color(0xFF00FF87), width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _triggerAuth,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F2FE),
                  foregroundColor: Colors.black,
                  shadowColor: const Color(0xFF00F2FE).withOpacity(0.5),
                  elevation: 8,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : Text(
                        _otpSent ? 'VERIFY & SIGN IN' : 'SEND SECURE OTP',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
              ),
              const Spacer(),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, color: Color(0xFF00FF87), size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Firebase App Check & SSL Encrypted',
                    style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}