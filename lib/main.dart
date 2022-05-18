import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:quicksend/client/quicksend_client.dart';
import 'package:quicksend/screens/homepage.dart';
import 'package:quicksend/screens/login_screen.dart';
import 'package:quicksend/utils/my_themes.dart';

void main() async {
  await dotenv.load();
  await quicksendClient.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quicksend',
      debugShowCheckedModeBanner: false,
      theme: MyThemes.mainTheme,
      home: const LoginScreen(),
    );
  }
}
