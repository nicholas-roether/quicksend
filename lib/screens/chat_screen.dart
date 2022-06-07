import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';
import 'package:quicksend/widgets/custom_text_form_field.dart';
import 'package:quicksend/widgets/image_source_dialog.dart';
import 'package:quicksend/widgets/message_box.dart';
import 'package:quicksend/widgets/profile_picture.dart';
import 'package:quicksend/widgets/small_fab_widget.dart';

import '../client/chat.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key, required this.userInfo, required this.chat})
      : super(key: key);
  final UserInfo userInfo;
  final Chat chat;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _chatController = TextEditingController();

  void _sendMessage() {
    if (_chatController.text.trim().isEmpty) return;
    setState(() {
      widget.chat.sendTextMessage(_chatController.text);
      _chatController.text = "";
    });
  }

  /*void _sendImageForWeb() async {
    final imageInfo = await ImagePickerWeb.getImageInfo;
    String? mimeType = mime(path.basename((imageInfo?.fileName)!));

    await widget.chat.sendMessage((mimeType)!, (imageInfo?.data)!);
  }*/

  void _sendImage(ImageSource source) async {
    File? pickedImage;
    final _picker = ImagePicker();
    try {
      final image = await _picker.pickImage(source: source);
      if (image == null) return;

      pickedImage = File(image.path);
      await widget.chat
          .sendMessage(mime(pickedImage.path)!, pickedImage.readAsBytesSync());
    } on PlatformException catch (_) {
      showDialog(
        context: context,
        builder: (context) {
          return const CustomErrorWidget(message: "Could not send image!");
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.chat.loadSavedMessages();
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Hero(
            tag: "username",
            child: Text(
              widget.userInfo.getName(),
              style: Theme.of(context).textTheme.headline5,
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ProfilePicture(userInfo: widget.userInfo),
            ),
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
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ImageSourceDialog(
                              iconButtonCallback: _sendImage);
                        },
                      );
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
                      inputType: TextInputType.multiline,
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
      ),
    );
  }
}
