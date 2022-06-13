import 'package:flutter/material.dart';

class MyThemes {
  static const Color _primaryColor = Color(0xffffcb5c);
  static const Color _secondaryColor = Color(0xff84826a);
  static const Color _backgroundColor = Color(0xFF0e0f19);

  static ThemeData mainTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      background: _backgroundColor,
      surface: _backgroundColor,
      shadow: Colors.transparent,
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _secondaryColor,
      contentTextStyle: TextStyle(fontFamily: "Quicksand"),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(shadowColor: Colors.transparent),
    scaffoldBackgroundColor: const Color(0xff0e0f19),
    bottomAppBarTheme: const BottomAppBarTheme(color: _backgroundColor),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: _backgroundColor,
      indicatorColor: _primaryColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: _backgroundColor,
      selectedItemColor: _primaryColor,
      unselectedItemColor: _secondaryColor,
    ),
    listTileTheme: const ListTileThemeData(iconColor: _primaryColor),
    iconTheme: const IconThemeData(color: Colors.black),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    fontFamily: 'Quicksand',
    inputDecorationTheme: const InputDecorationTheme(
      hintStyle: TextStyle(
        fontWeight: FontWeight.w500,
      ),
    ),
    textTheme: TextTheme(
      headlineLarge: const TextStyle(fontWeight: FontWeight.w500),
      headlineMedium: const TextStyle(fontWeight: FontWeight.w500),
      headlineSmall: const TextStyle(fontWeight: FontWeight.w500),
      titleLarge: const TextStyle(fontWeight: FontWeight.w500),
      titleMedium: const TextStyle(fontWeight: FontWeight.w500),
      titleSmall: const TextStyle(fontWeight: FontWeight.w500),
      labelLarge: TextStyle(foreground: Paint()..color = _secondaryColor),
      labelMedium: TextStyle(foreground: Paint()..color = _secondaryColor),
      labelSmall: TextStyle(foreground: Paint()..color = _secondaryColor),
    ).apply(
      displayColor: Colors.white,
      bodyColor: Colors.white,
    ),
  );
}
