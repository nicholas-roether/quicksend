import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:mime_type/mime_type.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/message_box.dart';
import 'package:path/path.dart' as path;
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

  void _sendImageForWeb() async {
    final imageInfo = await ImagePickerWeb.getImageInfo;
    String? mimeType = mime(path.basename((imageInfo?.fileName)!));

    await widget.chat.sendMessage((mimeType)!, (imageInfo?.data)!);
  }

  void _sendImageForMobile() async {
    final _picker = ImagePicker();
    XFile? pickedImage;
    Uint8List? byteImageData;
    String? mimeType = pickedImage?.mimeType;

    await _picker
        .pickImage(source: ImageSource.gallery)
        .then((value) => pickedImage = value);
    await pickedImage?.readAsBytes().then((value) => byteImageData = value);

    await widget.chat.sendMessage(mimeType!, byteImageData!);
  }

  @override
  Widget build(BuildContext context) {
    widget.chat.loadSavedMessages();
    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: "username",
          child: Text(
            widget.username,
            style: Theme.of(context).textTheme.headline5,
          ),
        ),
        centerTitle: true,
        actions: const [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: CircleAvatar(
              radius: 18,
            ),
          ), //add profile pic
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SmallFAB(
                  onPressedCallback: () {
                    if (kIsWeb) {
                      _sendImageForWeb();
                    } else {
                      _sendImageForMobile();
                    }
                  },
                  icon: Icons.image,
                ),
                const SizedBox(
                  width: 10,
                ),
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
          )
        ],
      ),
    );
  }
}
