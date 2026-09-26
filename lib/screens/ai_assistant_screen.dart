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
  
  // चैट मैसेजेस की लिस्ट
  List<Map<String, String>> _messages = [
    {"role": "ai", "text": "Hello! I am MechaniQ AI. How can I help you with your vehicle today?"}
  ];
  
  bool _isLoading = false;

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
      // असली सर्वर से जवाब मांगना
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

  // 🚀 यहाँ है असली सर्वर और "पासपोर्ट" का लॉजिक
  Future<String> _getSmartResponse(String input) async {
    // ⚠️ 1. यहाँ अपने असली सर्वर का URL डालें (http:// मत डालें, https:// डालें)
    final url = Uri.parse('https://YOUR_SERVER_URL.com/api/chat'); 

    try {
      final response = await http.post(
        url,
        // ⚠️ 2. यह है आपका "पासपोर्ट" (Headers) जिसे सर्वर चेक करेगा
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_SECRET_TOKEN', // अपना असली टोकन यहाँ डालें
          'x-api-key': 'YOUR_API_KEY' // अगर API की भी है, तो यहाँ डालें
        },
        // 3. आपका सवाल (JSON फॉर्मेट में)
        body: jsonEncode({
          "message": input
          // अगर आपका सर्वर 'query' या 'text' नाम से डेटा लेता है, तो "message" को बदल दें।
        }),
      );

      // 4. अगर सर्वर ने पासपोर्ट पास कर दिया (Status 200)
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        
        // ⚠️ ध्यान दें: अपने सर्वर के हिसाब से इसे बदलें। 
        // अगर आपका सर्वर {"reply": "Hello"} भेजता है, तो data['reply'] लिखें।
        return data['reply'] ?? data['response'] ?? data['message'] ?? "सर्वर से जवाब मिला पर पढ़ नहीं पाया।";
      } else {
        return "सर्वर ने रिजेक्ट कर दिया (Error: ${response.statusCode}) - कृपया API Key चेक करें।";
      }
    } catch (e) {
      return "सर्वर से कनेक्ट नहीं हो पा रहा है। Error: $e";
    }
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
    // UI का कोड बिल्कुल वैसा ही है (बिना किसी बदलाव के)
    return Scaffold(
      backgroundColor: Color(0xFF0D1117), 
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
