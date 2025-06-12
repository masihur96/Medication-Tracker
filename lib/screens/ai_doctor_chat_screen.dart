import 'package:flutter/material.dart';
import 'package:med_track/models/chat_model.dart';
import 'package:med_track/services/chat_repository.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../utils/app_localizations.dart';


class MedicationChatScreen extends StatefulWidget {
  const MedicationChatScreen({super.key});

  @override
  State<MedicationChatScreen> createState() => _MedicationChatScreenState();
}

class _MedicationChatScreenState extends State<MedicationChatScreen> {
  final ChatRepository _chatRepository = ChatRepository();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  final List<String> messages = [];
  bool _isLoading = false;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeSpeech();
    createChat("Act as an assistant doctor. ${_controller.text}");
  }

  Future<void> _initializeSpeech() async {
    await _speechToText.initialize();
    await _flutterTts.setLanguage("bn-BD"); // Set Bengali language
    await _flutterTts.setSpeechRate(0.5); // Adjust speech rate
  }

  Future<void> _startListening() async {
    if (!_isListening) {
      bool available = await _speechToText.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speechToText.listen(
          onResult: (result) {
            setState(() {
              _controller.text = result.recognizedWords;
            });
          },
          localeId: "bn_BD", // Set Bengali language
        );
      }
    }
  }

  Future<void> _stopListening() async {
    if (_isListening) {
      await _speechToText.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _speak(String text) async {
    await _flutterTts.speak(text);
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
    final localizations = AppLocalizations.of(context);
    return Scaffold(

      appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,

          title:  Text(localizations.medTrackAssistance)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length > 1 ? messages.length - 1 : 0,
              itemBuilder: (context, index) {
                final textMessage = messages[index + 1]; // Skip the first item
                final isUser = textMessage.startsWith("👤");
                return _buildMessageBubble(
                  text: textMessage,
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
          IconButton(
            icon: Icon(
              _isListening ? Icons.mic : Icons.mic_none,
              color: _isListening ? Colors.red : Colors.grey,
            ),
            onPressed: () {
              if (_isListening) {
                _stopListening();
              } else {
                _startListening();
              }
            },
          ),
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
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              shape: BoxShape.circle,
            ),
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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isUser ? Colors.white : Colors.black87,
                ),
              ),
            ),
            if (!isUser)
              IconButton(
                icon: const Icon(Icons.volume_up, size: 20),
                onPressed: () => _speak(text.replaceFirst("🤖 ডাক্তার: ", "")),
                color: isUser ? Colors.white : Colors.blue,
              ),
          ],
        ),
      ),
    );
  }
}
