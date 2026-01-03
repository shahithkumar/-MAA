import 'package:flutter/material.dart';
import 'chat_screen.dart';

void main() {
  runApp(const MaaApp());
}

class MaaApp extends StatelessWidget {
  const MaaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAA Mental Health Chatbot',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.white,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Colors.black,
          background: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: const ChatScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
