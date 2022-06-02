import 'package:flutter/material.dart';

class UserEditScreen extends StatelessWidget {
  const UserEditScreen({Key? key, required this.username}) : super(key: key);
  final String username;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          username,
          style: Theme.of(context).textTheme.headline5,
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [],
        ),
      ),
    );
  }
}
