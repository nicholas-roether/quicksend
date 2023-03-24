import 'package:flutter/material.dart';

class PaddingText extends StatelessWidget {
  PaddingText({Key? key, required this.text, this.padding = 15})
      : super(key: key);
  final String text;
  double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(padding),
      child: Text(
        text,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
    );
  }
}
