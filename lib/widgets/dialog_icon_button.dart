import 'package:flutter/material.dart';

class DialogIconButton extends StatelessWidget {
  const DialogIconButton(
      {Key? key,
      this.tooltip,
      required this.title,
      required this.onPressedCallback,
      required this.icon})
      : super(key: key);
  final String? tooltip;
  final String title;
  final void Function() onPressedCallback;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: onPressedCallback,
          iconSize: 40,
          icon: Icon(icon),
          tooltip: tooltip,
          splashRadius: 30,
          color: Theme.of(context).primaryColor,
        ),
        Text(
          title,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
