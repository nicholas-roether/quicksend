import 'dart:async';

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

  Stream<String> _showMessages() async* {
    for (int i = 0; i <= statements.length - 1; i++) {
      await Future.delayed(const Duration(seconds: 3));
      if (i == statements.length - 1) i = 0;
      yield statements[i];
    }
  }

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
          StreamBuilder<String>(
            initialData: statements[0],
            builder: (context, snapshot) {
              return Text(
                snapshot.data.toString(),
                style: Theme.of(context).textTheme.headline5,
                textAlign: TextAlign.center,
              );
            },
            stream: _showMessages(),
          ),
        ],
      ),
    );
  }
}
