import 'package:flutter/material.dart';

class SmallFAB extends StatelessWidget {
  const SmallFAB({Key? key, required this.onPressedCallback}) : super(key: key);
  final void Function() onPressedCallback;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      onPressed: onPressedCallback,
      child: const Icon(Icons.send),
      backgroundColor: Theme.of(context).primaryColor,
      elevation: 3,
    );
  }
}
