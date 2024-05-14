import 'dart:io';

import 'package:animate_gradient/animate_gradient.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _userPrompt = TextEditingController();
  final TextEditingController _userMessage = TextEditingController();
  bool _isLoading = false;

  final List<Message> _messages = [];

  //await dotenv.load();

  static final apiKey = Platform.environment['API_KEY'] ?? '';
  
  

  final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);


  // Add a ScrollController
  final _scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        title: const Text('ChatBot With Gemini'),
      ),
      body: AnimateGradient(
          primaryBegin: Alignment.topLeft,
       primaryEnd: Alignment.bottomLeft,
       secondaryBegin: Alignment.bottomLeft,
       secondaryEnd: Alignment.topRight,
       primaryColors: const [
         Colors.pink,
         Colors.pinkAccent,
         Colors.white,
       ],
       secondaryColors: const [
         Colors.white,
         Colors.blueAccent,
         Colors.blue,
       ],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Scrollbar(
              trackVisibility: true,
                controller: _scrollController,
                child: ListView.builder(
                  // List view to display the entire chat
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final msg = _messages[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: msg.isUser
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: 250), // Set a ma
                
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: msg.isUser ? Colors.blue : Colors.red,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  msg.message,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.clip,
                                ),
                                Text(
                                  '${msg.date.hour}:${msg.date.minute}',
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            _isLoading
                ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.pink, size: 60)
                : Padding(
                    // TextFormField to type in user prompt
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 15.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _userMessage,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              label: const Text('Chat with Gemini'),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed:
                              sendPrompt, // function to call the API with user prompt
                          padding: const EdgeInsets.all(15),
                          icon: const Icon(Icons.send),
                          iconSize: 30,
                        )
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> sendPrompt() async {
    final message = _userMessage.text;
    _userMessage.clear();

    setState(() {
      _isLoading = true;
      _messages
          .add(Message(message: message, isUser: true, date: DateTime.now()));
    });

    final prompt = [Content.text(message)];
    final response = await model.generateContent(prompt);

    setState(() {
      _isLoading = false;

      _messages.add(Message(
          message: response.text ?? '', isUser: false, date: DateTime.now()));

      // Scroll to the bottom of the list view
     
    });


if (_messages.isNotEmpty) {
   _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  
}
   
  }
}

class Messages {
  final String message;
  final bool isUser;
  final String date;

  const Messages(
      {required this.message, required this.isUser, required this.date});

  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: isUser ? Colors.blue : Colors.grey,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class Message {
  final String message;
  final bool isUser;
  final DateTime date;

  const Message(
      {required this.message, required this.isUser, required this.date});
}
