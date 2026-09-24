import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/app_colors.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({Key? key}) : super(key: key);

  @override
  _AiAssistantScreenState createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = []; // चैट हिस्ट्री सेव करने के लिए

  @override
  void initState() {
    super.initState();
    // वेलकम मैसेज
    _messages.add({
      "sender": "ai",
      "text": "Hello! I am MechaniQ AI. How can I help you with your vehicle today?"
    });
  }

  void _sendMessage() {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      // यूज़र का मैसेज ऐड करें
      _messages.add({"sender": "user", "text": text});
      _messageController.clear();
    });

    // AI का डमी रिप्लाई (बाद में इसे Cloudflare से जोड़ेंगे)
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _messages.add({
            "sender": "ai",
            "text": "I am analyzing your query regarding '$text'. Based on standard OBD2 protocols, this might require a diagnostic scan. Please connect your ELM327 scanner."
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: const Color(0xFF14243B),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: AppColors.primaryNeonBlue),
            const SizedBox(width: 10),
            Text(
              'MechaniQ AI',
              style: GoogleFonts.orbitron(
                color: AppColors.primaryNeonBlue,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // चैट लिस्ट
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(15),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                bool isUser = _messages[index]["sender"] == "user";
                return _buildChatBubble(_messages[index]["text"]!, isUser);
              },
            ),
          ),
          // मैसेज टाइप करने का बॉक्स
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primaryNeonBlue.withOpacity(0.2) : const Color(0xFF14243B),
          border: Border.all(color: isUser ? AppColors.primaryNeonBlue : Colors.white10),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.spaceGrotesk(
            color: isUser ? Colors.white : Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF14243B),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: SafeArea(
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
                  fillColor: AppColors.darkBackground,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: const BoxDecoration(
                color: AppColors.primaryNeonBlue,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.black),
                onPressed: _sendMessage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
