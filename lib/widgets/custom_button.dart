import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton(
      {Key? key, required this.pressedCallback, required this.title})
      : super(key: key);
  final void Function() pressedCallback;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: pressedCallback,
      child: Text(
        title,
      ),
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.of(context).size.width, 35),
      ),
    );
  }
}
