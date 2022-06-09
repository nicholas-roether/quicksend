import 'package:flutter/material.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/widgets/chat_tile.dart';
import 'package:quicksend/widgets/custom_error_alert_widget.dart';

class ChatList extends StatelessWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final quicksendClient = QuicksendClientProvider.get(context);
    return RefreshIndicator(
      onRefresh: () {
        return quicksendClient.refreshMessages();
      },
      child: AnimatedBuilder(
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
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(chats[index].recipientId),
                child: ChatTile(chat: chats[index]),
                confirmDismiss: (dismissDirection) async {
                  if (dismissDirection == DismissDirection.endToStart) {
                    try {
                      await quicksendClient
                          .getChatList()
                          .deleteChat(chats[index].recipientId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          duration: const Duration(seconds: 2),
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
                            message: "Something went wrong!",
                          );
                        },
                      );
                      return false;
                    }
                  }
                  if (dismissDirection == DismissDirection.startToEnd) {
                    try {
                      quicksendClient
                          .getChatList()
                          .removeChat(chats[index].recipientId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: Theme.of(context).primaryColor,
                          duration: const Duration(seconds: 2),
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
                            message: "Something went wrong!",
                          );
                        },
                      );
                      return false;
                    }
                  }
                  return null;
                },
                secondaryBackground: Container(
                  decoration: const BoxDecoration(color: Colors.red),
                  child: const Icon(Icons.delete),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                background: Container(
                  decoration:
                      BoxDecoration(color: Theme.of(context).primaryColor),
                  child: const Icon(Icons.archive),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                direction: DismissDirection.horizontal,
                // add removeChat function
              );
            },
            itemCount: chats.length,
          );
        },
      ),
    );
  }
}
