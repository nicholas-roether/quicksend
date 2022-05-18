import 'dart:html';

import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          margin: const EdgeInsets.only(
            top: 20,
          ),
          child: Column(
            children: [
              Text(
                "Login",
                style: Theme.of(context).textTheme.headline4,
              ),
              Form(child: Column()),
            ],
          ),
        ),
      ),
    );
  }
}
