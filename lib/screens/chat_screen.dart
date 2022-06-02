import 'package:flutter/material.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/message_box.dart';
import 'package:quicksend/widgets/small_fab_widget.dart';

import '../client/chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.username, required this.chat})
      : super(key: key);
  final String username;
  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();

  void _sendMessage() {
    if (_chatController.text.isEmpty) return;
    setState(() {
      widget.chat.sendTextMessage(_chatController.text);
      _chatController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    widget.chat.loadSavedMessages();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.username,
          style: Theme.of(context).textTheme.headline5,
        ),
        centerTitle: true,
        actions: const [
          CircleAvatar(), //add profile pic
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: AnimatedBuilder(
              animation: widget.chat,
              builder: (context, _) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    return MessageBox(
                      message: widget.chat.getMessages().elementAt(index),
                    );
                  },
                  itemCount: widget.chat.getMessages().length,
                  reverse: true,
                ),
              ),
            ),
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: CustomTextFormField(
                      hintInfo: "",
                      labelInfo: "Enter a Message",
                      obscure: false,
                      textController: _chatController,
                      submitCallback: (_) => _sendMessage(),
                      noPadding: true,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SmallFAB(
                    onPressedCallback: _sendMessage,
                    icon: Icons.send,
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
