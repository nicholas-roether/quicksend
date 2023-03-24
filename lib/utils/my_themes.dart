import 'package:flutter/material.dart';

class MyThemes {
  static const Color _primaryColor = Color(0xffffcb5c);
  static const Color _secondaryColor = Color(0xff84826a);
  static const Color _backgroundColor = Color(0xff0e0f19);
  static const Color _surfaceColor = Color(0xff1d1f34);

  static ThemeData mainTheme = ThemeData(
    colorScheme: const ColorScheme.dark(
      primary: _primaryColor,
      secondary: _secondaryColor,
      background: _backgroundColor,
      surface: _surfaceColor,
      shadow: Colors.transparent,
    ),
    dialogTheme: const DialogTheme(backgroundColor: _surfaceColor),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: _secondaryColor,
      contentTextStyle: TextStyle(
        fontFamily: "Quicksand",
        color: Colors.black,
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _primaryColor,
      foregroundColor: Colors.black,
    ),
    appBarTheme: const AppBarTheme(
      color: Colors.transparent,
      shadowColor: Colors.transparent,
    ),
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
    iconTheme: const IconThemeData(color: Colors.black, size: 30),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    popupMenuTheme: const PopupMenuThemeData(color: _surfaceColor),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(_primaryColor),
        textStyle: MaterialStateProperty.all(TextStyle(
          foreground: Paint()..color = _primaryColor,
          fontFamily: "Quicksand",
          fontWeight: FontWeight.w500,
        )),
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
      bodyLarge: const TextStyle(fontWeight: FontWeight.w500),
      bodyMedium: const TextStyle(fontWeight: FontWeight.w500),
      bodySmall: const TextStyle(fontWeight: FontWeight.w500),
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
