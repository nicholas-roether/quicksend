import 'package:flutter/material.dart';

class MyThemes {
  static ThemeData mainTheme = ThemeData(
    brightness: Brightness.dark,
    backgroundColor: const Color(0xFF0e0f19),
    primaryColor: const Color(0xFFffcb5c),
    primarySwatch: const MaterialColor(
      0xFFffcb5c,
      {
        50: Color(0xff9f7e39),
        100: Color(0xffaf8b3f),
        200: Color(0xffc09945),
        300: Color(0xffd3a84c),
        400: Color(0xffe8b954),
        500: Color(0xFFffcb5c),
        600: Color(0xffffd06b),
        700: Color(0xffffd478),
        800: Color(0xffffd884),
        900: Color(0xffffdc8f),
      },
    ),
    secondaryHeaderColor: const Color(0xFF84826a),
    scaffoldBackgroundColor: const Color(0xFF0e0f19),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF0e0f19),
      shadowColor: Colors.transparent,
    ),
    fontFamily: 'QuickSand',
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: const TextTheme(
      bodyText1: TextStyle(
        fontWeight: FontWeight.w400,
      ),
      bodyText2: TextStyle(
        fontWeight: FontWeight.w500,
      ),
      headline1: TextStyle(
        fontWeight: FontWeight.w400,
      ),
      headline2: TextStyle(
        fontWeight: FontWeight.w400,
      ),
      headline3: TextStyle(
        fontWeight: FontWeight.w400,
      ),
      headline4: TextStyle(
        fontWeight: FontWeight.w400,
      ),
      headline5: TextStyle(
        fontWeight: FontWeight.w400,
      ),
      headline6: TextStyle(
        fontWeight: FontWeight.w500,
      ),
    ),
  );
}
