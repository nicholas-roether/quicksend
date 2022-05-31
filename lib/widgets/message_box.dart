import 'package:flutter/material.dart';

class MessageBox extends StatelessWidget {
  const MessageBox({Key? key, required this.message, required this.color})
      : super(key: key);
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              ?.copyWith(color: Colors.black),
        ),
      ),
    );
  }
}
