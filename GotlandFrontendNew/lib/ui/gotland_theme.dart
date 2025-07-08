import 'package:flutter/material.dart';

class GotlandTheme {
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        surface: Colors.white,
        seedColor: Color.fromARGB(255, 0, 153, 0),
        dynamicSchemeVariant: DynamicSchemeVariant.content,
      ),
    );
  }
}
