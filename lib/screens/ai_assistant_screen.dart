import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_provider.dart';
import '../utils/app_colors.dart';

class AIAssistantScreen extends StatefulWidget {
  const AIAssistantScreen({Key? key}) : super(key: key);

  @override
  _AIAssistantScreenState createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends State<AIAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage(AIChatProvider provider) {
    if (_textController.text.isNotEmpty) {
      provider.sendMessage(_textController.text);
      _textController.clear();
      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final aiChatProvider = Provider.of<AIChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('MECHANIQ AI'),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              itemCount: aiChatProvider.messages.length,
              itemBuilder: (context, index) {
                final chat = aiChatProvider.messages[index];
                return Align(
                  alignment: chat.isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    padding: const EdgeInsets.all(14.0),
                    constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                    decoration: BoxDecoration(
                      color: chat.isUser ? AppColors.primaryNeonBlue.withOpacity(0.12) : AppColors.cardBackground,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16.0),
                        topRight: const Radius.circular(16.0),
                        bottomLeft: chat.isUser ? const Radius.circular(16.0) : const Radius.circular(0),
                        bottomRight: chat.isUser ? const Radius.circular(0) : const Radius.circular(16.0),
                      ),
                      border: Border.all(
                        color: chat.isUser ? AppColors.primaryNeonBlue : AppColors.borderCyan.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chat.isUser ? "YOU" : "MECHANIQ ENGINE AI",
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                            color: chat.isUser ? AppColors.primaryNeonBlue : AppColors.secondaryNeonOrange,
                          ),
                        ),
                        const SizedBox(height: 6.0),
                        Text(
                          chat.messageText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.0,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
              color: AppColors.cardBackground,
              border: Border(
                top: BorderSide(color: AppColors.borderCyan, width: 1.0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Type symptom (e.g. rough misfiring idle)...",
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: AppColors.borderCyan),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: AppColors.primaryNeonBlue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                    ),
                    onSubmitted: (_) => _sendMessage(aiChatProvider),
                  ),
                ),
                const SizedBox(width: 12.0),
                FloatingActionButton(
                  onPressed: () => _sendMessage(aiChatProvider),
                  backgroundColor: AppColors.primaryNeonBlue,
                  child: const Icon(Icons.send, color: AppColors.darkBackground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}