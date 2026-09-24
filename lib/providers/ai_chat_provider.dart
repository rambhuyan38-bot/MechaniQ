import 'package:flutter/material.dart';

class ChatMessage {
  final String messageText;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.messageText,
    required this.isUser,
    required this.timestamp,
  });
}

class AIChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [
    ChatMessage(
      messageText: "Hello, I am MechaniQ AI. Ask me anything about your OBD2 telemetry, DTCs, or routine vehicle diagnosis.",
      isUser: false,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    )
  ];

  List<ChatMessage> get messages => List.unmodifiable(_messages);

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(
      messageText: text,
      isUser: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _generateAIResponse(text);
  }

  Future<void> _generateAIResponse(String prompt) async {
    await Future.delayed(const Duration(seconds: 1));

    String aiResponse = "I can analyze that system for you. Based on the powertrain diagnostic protocols, please scan your ECU or provide specific telemetry figures to pinpoint the anomaly.";

    final cleanPrompt = prompt.toLowerCase();
    if (cleanPrompt.contains('misfire') || cleanPrompt.contains('p0302')) {
      aiResponse = "A P0302 code points specifically to Spark Plug/Coil Pack degradation. Swap Cylinder 2 and 3 coils. If the error shifts to P0303, replacing the coil pack is the primary resolution.";
    } else if (cleanPrompt.contains('lean') || cleanPrompt.contains('p0171')) {
      aiResponse = "P0171 suggests vacuum leaks. Check the air intake bellows and vacuum lines. Cleaning the MAF sensor often resolves intermittent issues with unmetered air flow.";
    } else if (cleanPrompt.contains('brakes') || cleanPrompt.contains('squeal')) {
      aiResponse = "Squealing brakes indicate either worn friction pads touching the rotor indicator or dust buildup. Check pad lining thickness (limit is 2mm minimum before replacement).";
    } else if (cleanPrompt.contains('overheating') || cleanPrompt.contains('coolant')) {
      aiResponse = "Warning: High thermal stress! Ensure the cooling fan triggers at 95°C. Check for coolant degradation or air pockets inside the radiator bypass lines.";
    }

    _messages.add(ChatMessage(
      messageText: aiResponse,
      isUser: false,
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}