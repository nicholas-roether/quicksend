import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/profile_picture.dart';
import 'package:skeletons/skeletons.dart';

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
    final quicksendClient = QuicksendClientProvider.get(context);
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
    return Dismissible(
      key: Key(userInfo!.username),
      /*confirmDismiss: (dismissDirection) async {
        if (dismissDirection == DismissDirection.endToStart) {
          try {
            await quicksendClient
                .getChatList()
                .deleteChat(widget.chat.recipientId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                margin: const EdgeInsets.all(5),
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "Deleted chat",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.black),
                ),
              ),
            );
            return true;
          } on Exception catch (_) {
            showDialog(
              context: context,
              builder: (context) {
                return const CustomErrorWidget(
                    message: "Something went wrong!");
              },
            );
            return false;
          }
        }
        if (dismissDirection == DismissDirection.startToEnd) {
          try {
            quicksendClient.getChatList().removeChat(widget.chat.recipientId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                backgroundColor: Theme.of(context).primaryColor,
                margin: const EdgeInsets.all(5),
                behavior: SnackBarBehavior.floating,
                content: Text(
                  "Archived chat",
                  style: Theme.of(context)
                      .textTheme
                      .bodyText2
                      ?.copyWith(color: Colors.black),
                ),
              ),
            );
            return true;
          } on Exception catch (_) {
            showDialog(
              context: context,
              builder: (context) {
                return const CustomErrorWidget(
                    message: "Something went wrong!");
              },
            );
            return false;
          }
        }
        return null;
      },*/
      secondaryBackground: Container(
        decoration: const BoxDecoration(color: Colors.red),
        child: const Icon(Icons.delete),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
      background: Container(
        decoration: BoxDecoration(color: Theme.of(context).primaryColor),
        child: const Icon(Icons.archive),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
      ),
      direction: DismissDirection.none, // dismissdirection to horizontal
      // add removeChat function
      child: ListTile(
        leading: ProfilePicture(userInfo: userInfo!),
        title: Hero(
          tag: "username" + userInfo!.username,
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
      ),
    );
  }
}
