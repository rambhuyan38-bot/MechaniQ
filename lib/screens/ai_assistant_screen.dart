import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class AiAssistantScreen extends StatefulWidget {
  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  // चैट मैसेजेस की असली लिस्ट
  List<Map<String, String>> _messages = [
    {"role": "ai", "text": "Hello! I am MechaniQ AI. How can I help you with your vehicle today?"}
  ];
  
  bool _isLoading = false;

  // असली AI से बात करने का फंक्शन
  Future<void> _sendMessage() async {
    String userText = _messageController.text.trim();
    if (userText.isEmpty) return;

    setState(() {
      _messages.add({"role": "user", "text": userText});
      _messageController.clear();
      _isLoading = true;
    });

    _scrollToBottom();

    try {
      // ⚠️ यहाँ आपका असली Cloudflare AI या Gemini API का लिंक आएगा
      // अभी के लिए मैंने एक स्मार्ट डमी लॉजिक डाला है ताकि यह आपकी बात का मतलब समझे
      String aiResponse = await _getSmartResponse(userText);
      
      setState(() {
        _messages.add({"role": "ai", "text": aiResponse});
        _isLoading = false;
      });
      _scrollToBottom();
      
    } catch (e) {
      setState(() {
        _messages.add({"role": "ai", "text": "Sorry, server connection failed. Please check your internet."});
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  // डमी से हटाकर स्मार्ट कीवर्ड आधारित लॉजिक (जब तक API की चाबी न लगे)
  Future<String> _getSmartResponse(String input) async {
    await Future.delayed(Duration(seconds: 2)); // असली लोडिंग की फील
    String lowerInput = input.toLowerCase();

    if (lowerInput.contains("logon") || lowerInput.contains("meter")) {
      return "मीटर पर लाइट (Logon) आने का मतलब है कि गाड़ी के किसी सेंसर में दिक्कत है (जैसे Check Engine या ABS)। सटीक कारण जानने के लिए कृपया अपना OBD2 स्कैनर कनेक्ट करें।";
    } else if (lowerInput.contains("starting") || lowerInput.contains("start")) {
      return "अगर गाड़ी स्टार्ट नहीं हो रही है, तो सबसे पहले अपनी बैटरी वोल्टेज (12.4V से ऊपर) चेक करें और स्पार्क प्लग की जांच करें।";
    } else if (lowerInput.contains("mileage") || lowerInput.contains("average")) {
      return "माइलेज कम होने के कई कारण हो सकते हैं: गंदा एयर फिल्टर, कम टायर प्रेशर, या खराब ऑक्सीजन (O2) सेंसर।";
    }
    
    return "मैं आपकी समस्या का विश्लेषण कर रहा हूँ। बेहतर जानकारी के लिए कृपया अपने OBD2 स्कैनर से डायग्नोस्टिक स्कैन रन करें।";
  }

  void _scrollToBottom() {
    Future.delayed(Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), // MechaniQ Theme
      appBar: AppBar(
        backgroundColor: Color(0xFF161B22),
        title: Row(
          children: [
            Icon(Icons.smart_toy, color: Colors.cyanAccent),
            SizedBox(width: 10),
            Text("MechaniQ AI", style: GoogleFonts.orbitron(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                bool isUser = msg["role"] == "user";
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: EdgeInsets.only(bottom: 12),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.transparent : Color(0xFF161B22),
                      border: isUser ? Border.all(color: Colors.cyanAccent) : null,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft: isUser ? Radius.circular(16) : Radius.circular(0),
                        bottomRight: isUser ? Radius.circular(0) : Radius.circular(16),
                      ),
                    ),
                    child: Text(
                      msg["text"]!,
                      style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 14, height: 1.5),
                    ),
                  ),
                );
              },
            ),
          ),
          
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: SpinKitThreeBounce(color: Colors.cyanAccent, size: 20),
              ),
            ),
            
          // Input Field UI
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            color: Color(0xFF161B22),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.spaceGrotesk(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Ask about your car's problem...",
                      hintStyle: GoogleFonts.spaceGrotesk(color: Colors.white38),
                      filled: true,
                      fillColor: Color(0xFF0D1117),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                GestureDetector(
                  onPressed: _sendMessage,
                  child: CircleAvatar(
                    backgroundColor: Colors.cyanAccent,
                    child: Icon(Icons.send, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
