import 'package:flutter/material.dart';

class AppColors {
  static const Color lightPrimary = Color(0xFF1E1E1E);
  static const Color lightSecondary = Color(0xFF424242);
  static const Color lightAccent = Color(0xFFFF6B6B);
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Color(0xFFFFFFFF);

  static const Color darkPrimary = Color(0xFF121212);
  static const Color darkSecondary = Color(0xFF2C2C2C);
  static const Color darkAccent = Color(0xFF4ECDC4);
  static const Color darkBackground = Color(0xFF0D0D0D);
  static const Color darkSurface = Color(0xFF1E1E1E);

  static const Color operatorButtonLight = Color(0xFFE0E0E0);
  static const Color operatorButtonDark = Color(0xFF3D3D3D);
  static const Color numberButtonLight = Color(0xFFFFFFFF);
  static const Color numberButtonDark = Color(0xFF2C2C2C);
  static const Color equalsButtonLight = Color(0xFFFF6B6B);
  static const Color equalsButtonDark = Color(0xFF4ECDC4);
  static const Color functionButtonLight = Color(0xFFE8E8E8);
  static const Color functionButtonDark = Color(0xFF4A4A4A);
  static const Color clearButtonLight = Color(0xFFFF6B6B);
  static const Color clearButtonDark = Color(0xFFD45050);
}

class AppFonts {
  static const String fontFamily = 'Roboto';

  static const TextStyle buttonText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle displayText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle historyText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w300,
  );

  static const TextStyle modeText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

class AppDimensions {
  static const double buttonSpacing = 8.0;
  static const double buttonBorderRadius = 14.0;
  static const double borderRadiusDisplay = 20.0;
  static const double screenPadding = 16.0;
  static const Duration animationDuration = Duration(milliseconds: 150);
  static const Duration modeTransitionDuration = Duration(milliseconds: 300);
}

class StorageKeys {
  static const String history = 'calculation_history';
  static const String settings = 'calculator_settings';
  static const String memory = 'calculator_memory';
}
