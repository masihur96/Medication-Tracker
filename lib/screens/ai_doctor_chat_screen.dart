import 'package:flutter/material.dart';
class AIDoctorChatScreen extends StatelessWidget {
  const AIDoctorChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Doctor"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "👨‍⚕️ Welcome to your AI Doctor Chat!\n\n"
              "This is where intelligent assistance can be integrated.",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
