import 'package:flutter/material.dart';

class SmallFAB extends StatelessWidget {
  const SmallFAB(
      {Key? key, required this.onPressedCallback, required this.icon})
      : super(key: key);
  final void Function() onPressedCallback;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.small(
      heroTag: icon,
      onPressed: onPressedCallback,
      child: Icon(icon),
      elevation: 3,
    );
  }
}
