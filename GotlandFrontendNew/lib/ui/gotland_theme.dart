import 'package:flutter/material.dart';

class GotlandTheme {
  static ThemeData lightThemeData(BuildContext context) {
    return ThemeData(
      fontFamily: 'Roboto',
      textTheme: TextTheme.of(context).apply(fontSizeFactor: 1.2, letterSpacingDelta: -0.5, heightFactor: 0.9),
      colorScheme: ColorScheme.fromSeed(
        surface: Colors.white,
        seedColor: Color.fromARGB(255, 0, 153, 0),
        dynamicSchemeVariant: DynamicSchemeVariant.content,
      ),
      useMaterial3: true,
    );
  }
}
