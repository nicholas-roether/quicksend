import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.message}) : super(key: key);
  final Message message;

  Widget messageBoxContent(context) {
    switch (message.type) {
      case "text/plain":
        return Text(
          message.asString(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              ?.copyWith(color: Colors.black),
        );
      case "image/jpeg":
        return Image.memory(message.content);
      case "image/png":
        return Image.memory(message.content);
    }
    return const Text("message corrupted!");
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.direction == MessageDirection.outgoing
          ? const Alignment(1.0, 1.0)
          : const Alignment(-1.0, 1.0),
      child: Card(
        elevation: 2,
        color: message.direction == MessageDirection.outgoing
            ? Theme.of(context).primaryColor
            : Theme.of(context).secondaryHeaderColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: messageBoxContent(context),
        ),
      ),
    );
  }
}
