import 'dart:io';

import 'package:flutter/foundation.dart';
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

  Future<void> _sendMessage() async {
    if (_chatController.text.trim().isEmpty) return;
    widget.chat.sendTextMessage(_chatController.text);
    setState(() {
      _chatController.text = "";
    });
  }

  /*Future<void> _sendImageForWeb() async {
    final imageInfo = await ImagePickerWeb.getImageInfo;
    if (imageInfo == null) return;
    String? mimeType = mime(path.basename((imageInfo.fileName)!));

    // Configuration config = const Configuration(
    //   outputType: ImageOutputType.webpThenJpg,
    //   quality: 25,
    // );

    // var input =
    //     ImageFile(filePath: imageInfo.fileName!, rawBytes: imageInfo.data!);
    // var param = ImageFileConfiguration(input: input, config: config);
    // var output = await compressor.compress(param);
    if (imageInfo.data!.length >= 2097152) {
      return showDialog(
        context: context,
        builder: (context) {
          return const CustomErrorWidget(
            message: "Images can't be larger than 2MB",
          );
        },
      );
    }
    await widget.chat.sendMessage((mimeType)!, imageInfo.data!);
  }*/

  Future<void> _sendImage(ImageSource source) async {
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
    Navigator.pop(context);
  }

  void redrawBeforeAndAfter(Future future) {
    future.then((_) => setState((() {})));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    widget.chat.loadSavedMessages();
    if (widget.chat.hasUnreadMessages()) {
      widget.chat.markAsRead().then((value) {
        if (!mounted) return;
        setState(() {});
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, "/user_profile",
                arguments: widget.userInfo);
          },
          child: Text(
            widget.userInfo.getName(),
            style: Theme.of(context).textTheme.headlineSmall,
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
                //image sender
                SmallFAB(
                  onPressedCallback: () {
                    if (kIsWeb) {
                      //redrawBeforeAndAfter(_sendImageForWeb());
                    } else {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return ImageSourceDialog(
                            iconButtonCallback: (image) =>
                                redrawBeforeAndAfter(_sendImage(image)),
                          );
                        },
                      );
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
                    minLines: 1,
                    maxLines: 5,
                    labelInfo: "Enter a Message",
                    obscure: false,
                    inputType: TextInputType.multiline,
                    textController: _chatController,
                    submitCallback: (_) => redrawBeforeAndAfter(
                      _sendMessage(),
                    ),
                    noPadding: true,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //message sender
                SmallFAB(
                  onPressedCallback: () => redrawBeforeAndAfter(
                    _sendMessage(),
                  ),
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
