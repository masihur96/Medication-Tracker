import 'package:flutter/material.dart';
import 'package:med_track/models/chat_model.dart';
import 'package:med_track/services/chat_repository.dart';


class MedicationChatScreen extends StatefulWidget {
  const MedicationChatScreen({super.key});

  @override
  State<MedicationChatScreen> createState() => _MedicationChatScreenState();
}

class _MedicationChatScreenState extends State<MedicationChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    createChat("Act as an assistant doctor. ${_controller.text}");
  }

  createChat(String text) async {

    setState(() {
      _isLoading = true;
      messages.add("👤 আপনি: $text");
    });

    String prompt = "You are a knowledgeable and helpful assistant doctor. Answer in Bengali. User: $text";


    _scrollToBottom();
    ChatBootModel? chatBootModelData = await _chatRepository.createChat(text: prompt);
    if (chatBootModelData != null) {
      setState(() {
        messages.add("🤖 ডাক্তার: ${chatBootModelData.choices.first.message?.content}");
      });
      _scrollToBottom();
    }

    setState(() {
      _isLoading = false;
    });
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,

          title: const Text('MedTrack Assistance')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length > 1 ? messages.length - 1 : 0,
              itemBuilder: (context, index) {
                final textMessage = messages[index + 1]; // Skip the first item
                final isUser = textMessage.startsWith("You:");
                return _buildMessageBubble(
                  text: textMessage.replaceFirst("You: ", "").replaceFirst("Bot: ", ""),
                  isUser: isUser,
                );
              },
            )

          ),
          if (_isLoading) const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: CircularProgressIndicator(),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Type a message...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onSubmitted: (_) => _onSendPressed(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration:  BoxDecoration(color:  Theme.of(context).primaryColor, shape: BoxShape.circle),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _isLoading ? null : _onSendPressed,
            ),
          ),
        ],
      ),
    );
  }

  void _onSendPressed() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      createChat(text);
      _controller.clear();
    }
  }

  Widget _buildMessageBubble({required String text, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: isUser ? Colors.blue : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 16,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
