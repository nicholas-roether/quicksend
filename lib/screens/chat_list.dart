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
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
            );
          }
          return ListView.builder(
            itemBuilder: (context, index) {
              return Dismissible(
                key: Key(chats[index].recipientId),
                child: ChatTile(chat: chats[index]),
                onDismissed: (direction) async {
                  if (direction == DismissDirection.endToStart) {
                    try {
                      await quicksendClient
                          .getChatList()
                          .deleteChat(chats[index].recipientId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text("Deleted chat"),
                        ),
                      );
                    } on Exception catch (_) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const CustomErrorWidget(
                            message: "Something went wrong!",
                          );
                        },
                      );
                    }
                  }
                  if (direction == DismissDirection.startToEnd) {
                    try {
                      await quicksendClient
                          .getChatList()
                          .archiveChat(chats[index].recipientId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          duration: Duration(seconds: 2),
                          content: Text("Archived chat"),
                        ),
                      );
                    } on Exception catch (_) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const CustomErrorWidget(
                            message: "Something went wrong!",
                          );
                        },
                      );
                    }
                  }
                },
                confirmDismiss: (dismissDirection) async {
                  if (dismissDirection == DismissDirection.endToStart) {
                    return await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('Are you sure?'),
                          content: const Text(
                              "This action will delete all messages from this device!"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(true);
                              },
                              child: const Text('Sure!'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false);
                              },
                              child: const Text('Nope'),
                            )
                          ],
                        );
                      },
                    );
                  }
                  return true;
                },
                secondaryBackground: Container(
                  decoration: const BoxDecoration(color: Colors.red),
                  child: const Icon(Icons.delete, color: Colors.white),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  child: const Icon(Icons.archive, color: Colors.white),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                direction: DismissDirection.horizontal,
              );
            },
            itemCount: chats.length,
          );
        },
      ),
    );
  }
}
