import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';
import 'package:skeletons/skeletons.dart';

import '../client/chat.dart';
import '../screens/chat_screen.dart';

class ChatTile extends StatefulWidget {
  const ChatTile({Key? key, required this.chat}) : super(key: key);
  final Chat chat;

  @override
  State<ChatTile> createState() => _ChatTileState();
}

class _ChatTileState extends State<ChatTile> {
  UserInfo? userInfo;

  @override
  Widget build(BuildContext context) {
    widget.chat.getRecipient().then((value) {
      setState(() {
        userInfo = value;
      });
    });
    if (userInfo == null) {
      return SkeletonListTile(
        hasLeading: true,
        hasSubtitle: true,
      );
    }
    return ListTile(
      leading: const CircleAvatar(),
      title: Text(
        userInfo!.getName(),
        style: Theme.of(context).textTheme.headline6,
      ),
      /*subtitle: Text(
        "Last Message",
        style: Theme.of(context).textTheme.bodyText1,
      ),*/
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              username: userInfo!.getName(),
              chat: widget.chat,
            );
          },
        ),
      ),
    );
  }
}
