import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:quicksend/widgets/message_box.dart';
import 'package:quicksend/widgets/small_fab_widget.dart';
import 'package:path/path.dart' as path;

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

  void _sendImage() async {
    final imageInfo = await ImagePickerWeb.getImageInfo;
    String? mimeType = mime(path.basename((imageInfo?.fileName)!));

    await widget.chat.sendMessage((mimeType)!, (imageInfo?.data)!);
  }

  @override
  Widget build(BuildContext context) {
    widget.chat.loadSavedMessages();
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
                  SmallFAB(
                    onPressedCallback: _sendImage,
                    icon: Icons.image,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
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
