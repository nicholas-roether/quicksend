import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingIndicator extends StatelessWidget {
  LoadingIndicator({
    Key? key,
  }) : super(key: key);
  final List<String> statements = [
    "Loading...",
    "Refactoring the whole database...",
    "Trying to find your brain...",
    "Generating RSA Key...",
    "Generating your Chatlist..."
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LoadingAnimationWidget.dotsTriangle(
            color: Theme.of(context).primaryColor,
            size: 50,
          ),
          Text(
            "Loading...",
            style: Theme.of(context).textTheme.headline4,
          )
        ],
      ),
    );
  }
}
