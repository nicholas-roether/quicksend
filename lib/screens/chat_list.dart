import 'package:flutter/material.dart';
import 'chat_screen.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) => ListTile(
        leading: const CircleAvatar(),
        title: Text(
          'Username: ${index + 1}',
          style: Theme.of(context).textTheme.headline6,
        ),
        subtitle: Text(
          "Last Message",
          style: Theme.of(context).textTheme.bodyText1,
        ),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ChatScreen(
                username: "Username: ${index + 1}",
              );
            },
          ),
        ),
      ),
      itemCount: 20,
    );
  }
}
