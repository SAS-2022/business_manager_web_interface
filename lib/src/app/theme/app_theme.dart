import 'package:flutter/material.dart';

class AppTheme {
  static final lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        surfaceTintColor: WidgetStateProperty.all(Colors.black),
      ),
    ),
    dialogTheme: const DialogThemeData(
        backgroundColor: Colors.white, surfaceTintColor: Colors.white),
    colorScheme: ColorScheme.fromSeed(
        primary: Colors.black,
        primaryFixed: Colors.grey[200],
        primaryContainer: const Color.fromARGB(255, 158, 190, 206),
        onPrimaryContainer: const Color.fromARGB(255, 221, 240, 246),
        onPrimaryFixed: Colors.green,
        onPrimaryFixedVariant: const Color.fromARGB(255, 176, 203, 177),
        secondary: Colors.white,
        secondaryFixed: const Color.fromARGB(255, 46, 92, 130),
        onSecondary: Colors.amber,
        secondaryContainer: const Color.fromARGB(255, 99, 121, 147),
        outline: Colors.amberAccent,
        seedColor: Colors.blue,
        brightness: Brightness.light,
        surface: const Color.fromARGB(255, 79, 100, 136),
        surfaceContainer: const Color.fromARGB(255, 191, 188, 177),
        error: Colors.red),
  );

  static final darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    useMaterial3: true,
    dropdownMenuTheme: DropdownMenuThemeData(
      menuStyle: MenuStyle(
        surfaceTintColor: WidgetStateProperty.all(Colors.black),
      ),
    ),
    dialogTheme: const DialogThemeData(
        backgroundColor: Color.fromARGB(255, 53, 52, 52),
        surfaceTintColor: Color.fromARGB(255, 53, 52, 52)),
    colorScheme: ColorScheme.fromSeed(
        primary: Colors.white,
        primaryFixed: Colors.grey[700],
        onPrimaryContainer: const Color.fromARGB(255, 118, 175, 193),
        primaryContainer: const Color.fromARGB(255, 44, 106, 137),
        onPrimaryFixed: Colors.green,
        onPrimaryFixedVariant: const Color.fromARGB(255, 151, 210, 153),
        secondary: Colors.black,
        secondaryContainer: const Color.fromARGB(255, 85, 103, 125),
        secondaryFixed: const Color.fromARGB(255, 46, 112, 125),
        onSecondary: const Color.fromARGB(255, 230, 196, 83),
        outline: Colors.amberAccent,
        seedColor: Colors.blue,
        brightness: Brightness.dark,
        surface: const Color.fromARGB(255, 9, 74, 96),
        surfaceContainer: const Color.fromARGB(255, 53, 52, 52),
        error: Colors.red),
  );
}
