import 'package:flutter/material.dart';

class AiChatProvider extends ChangeNotifier {
  final List<Map<String, String>> _messages = [];
  List<Map<String, String>> get messages => _messages;

  void sendMessage(String text) {
    _messages.add({'sender': 'user', 'text': text});
    notifyListeners();
    
    // Mock response trigger
    Future.delayed(const Duration(milliseconds: 500), () {
      _messages.add({'sender': 'ai', 'text': 'MechaniQ AI is currently in offline demo mode. Let us know how your car is behaving!'});
      notifyListeners();
    });
  }
}