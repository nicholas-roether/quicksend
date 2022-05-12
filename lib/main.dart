import 'package:flutter/material.dart';
import 'package:quicksend/screens/homepage.dart';
import 'package:quicksend/screens/settings_screen.dart';
import 'package:quicksend/utils/my_themes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: MyThemes.mainTheme,
      routes: {
        "/settings": (context) => const SettingScreen(),
      },
      home: const HomePage(),
    );
  }
}
