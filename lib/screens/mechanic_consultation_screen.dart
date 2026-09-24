import 'package:flutter/material.dart';

class MechanicConsultationScreen extends StatefulWidget {
  const MechanicConsultationScreen({super.key});

  @override
  State<MechanicConsultationScreen> createState() => _MechanicConsultationScreenState();
}

class _MechanicConsultationScreenState extends State<MechanicConsultationScreen> {
  bool _isPaymentDone = false;
  bool _isConnecting = false;

  void _triggerMockUpiPayment() async {
    setState(() {
      _isConnecting = true;
    });
    // Simulate Razorpay / BHIM UPI redirection gateway delay
    await Future.delayed(const Duration(seconds: 3));
    setState(() {
      _isConnecting = false;
      _isPaymentDone = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Consultation'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            if (!_isPaymentDone && !_isConnecting) ...[
              const Icon(Icons.forum, size: 72, color: Color(0xFF00F2FE)),
              const SizedBox(height: 24),
              const Text(
                'Connect with a Premium Tech-Mechanic',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Instant secure 5-minute technical live chat and diagnostic breakdown with a verified expert. Charge: ₹149 only.',
                style: TextStyle(color: Color(0xFFC5C6C7), fontSize: 14, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: _triggerMockUpiPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FF87),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.payment, color: Colors.black),
                    SizedBox(width: 8),
                    Text('SECURE PAY WITH RAZORPAY / UPI', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ] else if (_isConnecting) ...[
              const Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(color: Color(0xFF00FF87)),
                    SizedBox(height: 24),
                    Text('Authenticating Secured Gateway via Razorpay API...', style: TextStyle(color: Color(0xFF00F2FE))),
                  ],
                ),
              )
            ] else ...[
              const Icon(Icons.verified, size: 72, color: Color(0xFF00FF87)),
              const SizedBox(height: 24),
              const Text(
                'Payment Verified! Connecting...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Card(
                color: Color(0xFF1F2833),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(backgroundColor: Color(0xFF00F2FE), child: Icon(Icons.person, color: Colors.black)),
                      SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Mechanic: Vikram Singh', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          SizedBox(height: 4),
                          Text('Connected & ready to chat', style: TextStyle(color: Color(0xFF00FF87), fontSize: 12)),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type diagnostic query...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        fillColor: const Color(0xFF1F2833),
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF00FF87)),
                    onPressed: () {},
                  )
                ],
              )
            ],
            const Spacer(),
          ],
        ),
      ),
    );
  }
}