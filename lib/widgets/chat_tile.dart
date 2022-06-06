import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';
import 'package:quicksend/widgets/profile_picture.dart';
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

  String getLastMessage() {
    if (widget.chat.getLatestMessage() != null) {
      switch (widget.chat.getLatestMessage()!.type) {
        case "text/plain":
          return widget.chat.getLatestMessage()!.asString();
        case "image/jpeg":
          return "Image";
        case "image/png":
          return "Image";
      }
    }
    return "message...";
  }

  @override
  Widget build(BuildContext context) {
    widget.chat.getRecipient().then((value) {
      if (!mounted) return;
      setState(() {
        userInfo = value;
      });
    });
    if (userInfo == null) {
      return SkeletonListTile(
        hasLeading: true,
        hasSubtitle: true,
        leadingStyle: SkeletonAvatarStyle(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 15),
      );
    }
    return ListTile(
      leading: ProfilePicture(userInfo: userInfo!),
      title: Hero(
        tag: "username",
        child: Text(
          userInfo!.getName(),
          style: Theme.of(context).textTheme.headline6,
        ),
      ),
      subtitle: Text(
        getLastMessage(),
        style: Theme.of(context)
            .textTheme
            .bodyText1
            ?.copyWith(color: Theme.of(context).secondaryHeaderColor),
      ),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ChatScreen(
              userInfo: userInfo!,
              chat: widget.chat,
            );
          },
        ),
      ),
    );
  }
}
