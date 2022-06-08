import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/chat_tile.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quicksendClient = QuicksendClientProvider.get(context);
    return AnimatedBuilder(
      animation: quicksendClient.getChatList(),
      builder: (context, _) {
        final chats = quicksendClient.getChatList().getChats();
        if (chats.isEmpty) {
          return Center(
            child: Text(
              'Press the "+" button to add a chat',
              style: Theme.of(context).textTheme.headline4,
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          itemBuilder: (context, index) => ChatTile(chat: chats[index]),
          itemCount: chats.length,
        );
      },
    );
  }
}
