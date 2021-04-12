import 'package:flutter/material.dart';

const PRIMARY_COLOR = Color.fromARGB(255, 141, 0, 119);
const ACCENT_COLOR = Color.fromARGB(255, 200, 142, 0);
const BUTTON_COLOR = Color.fromARGB(255, 0, 120, 120);

ThemeData getTheme() {
  // https://paletton.com/#uid=34+170kOlp2rfRiO9GhQXg6YA2E
  return ThemeData(
    brightness: Brightness.dark,
    primaryColor: PRIMARY_COLOR,
    accentColor: ACCENT_COLOR,
    textButtonTheme: getTextButtonThemeData(),
    elevatedButtonTheme: getElevatedButtonThemeData(),
    outlinedButtonTheme: getOutlinedButtonThemeData(),
  );
}

TextButtonThemeData getTextButtonThemeData() {
  return TextButtonThemeData(
      style: TextButton.styleFrom(primary: BUTTON_COLOR));
}

ElevatedButtonThemeData getElevatedButtonThemeData() {
  return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(primary: BUTTON_COLOR));
}

OutlinedButtonThemeData getOutlinedButtonThemeData() {
  return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(primary: BUTTON_COLOR));
}
