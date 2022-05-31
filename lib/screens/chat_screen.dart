import 'package:flutter/material.dart';
import 'package:quicksend/widgets/message_box.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();
  List<String> messages = [];

  void _sendMessage() {
    if (_chatController.text.isEmpty) return;
    setState(() {
      messages.insert(0, _chatController.text);
      _chatController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.username,
          style: Theme.of(context).textTheme.bodyText1,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: ListView.builder(
              itemBuilder: (context, index) {
                return Align(
                  alignment: const Alignment(0.9, 1.0),
                  child: MessageBox(
                    message: messages[index],
                    color: Theme.of(context).primaryColor,
                  ),
                );
              },
              itemCount: messages.length,
              reverse: true,
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(
                        fontSize: 20,
                      ),
                      controller: _chatController,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.fromLTRB(8, 3, 8, 3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  FloatingActionButton.small(
                    onPressed: _sendMessage,
                    child: const Icon(Icons.send),
                    backgroundColor: Theme.of(context).primaryColor,
                    elevation: 3,
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
