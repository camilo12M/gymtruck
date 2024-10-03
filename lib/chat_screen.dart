import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gymtrack/chat_bot_service..dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ChatBotService _chatBotService = ChatBotService();

  void _sendMessage() {
    final message = _controller.text;
    if (message.isEmpty) return;

    _controller.clear();
    _addMessage(message, 'user');

    _chatBotService.getResponse(message).then((response) {
      _addMessage(response, 'bot');
    }).catchError((error) {
      _addMessage('Error: $error', 'bot');
    });
  }

  void _addMessage(String message, String sender) {
    setState(() {
      _messages.add({'message': message, 'sender': sender});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('GymTrack ChatBot'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final isUser = _messages[index]['sender'] == 'user';
                return Align(
                  alignment:
                      isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue : Colors.green,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                        bottomLeft:
                            isUser ? Radius.circular(16) : Radius.circular(0),
                        bottomRight:
                            isUser ? Radius.circular(0) : Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _messages[index]['message']!,
                          style: GoogleFonts.manjari(
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          isUser ? 'You' : 'Bot',
                          style: TextStyle(color: Colors.white70, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: GoogleFonts.manjari(
                        fontWeight: FontWeight.w400,
                        color:
                            Colors.white), // Cambia el color del texto a blanco
                    decoration: const InputDecoration(
                      hintText: 'Escribe un mensaje',
                      hintStyle: TextStyle(
                          color: Colors.grey), // Cambia el color del hint
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
