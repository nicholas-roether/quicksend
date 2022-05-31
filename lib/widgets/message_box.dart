import 'package:flutter/material.dart';
import 'package:quicksend/client/models.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.message, required this.color})
      : super(key: key);
  final Message message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message.asString(),
          style: Theme.of(context)
              .textTheme
              .bodyText1
              ?.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
