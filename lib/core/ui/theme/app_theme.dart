import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.redAccent.shade700,
        primary: Colors.redAccent.shade200,
        secondary: Colors.green,
      ),

      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(fontSize: 16, height: 1.5),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        isDense: true,
        contentPadding: const EdgeInsets.all(16),

        enabledBorder: _buildBorder(Colors.grey.shade400),
        focusedBorder: _buildBorder(Colors.blue.shade700),
        errorBorder: _buildBorder(Colors.red.shade700),
        focusedErrorBorder: _buildBorder(Colors.red.shade700),
        disabledBorder: _buildBorder(Colors.grey.shade300),
        border: _buildBorder(Colors.grey.shade400),

        labelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
        errorStyle: TextStyle(fontSize: 12, color: Colors.red.shade700),
        helperStyle: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        errorMaxLines: 2,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          elevation: 1,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
        ),
      ),

      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),

      appBarTheme: AppBarTheme(
        elevation: 4,
        centerTitle: true,
        shadowColor: Colors.red.shade100,
        titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
      ),
    );
  }

  static OutlineInputBorder _buildBorder(Color color) {
    return OutlineInputBorder(
      borderSide: BorderSide(width: 1, color: color),
      borderRadius: BorderRadius.circular(10),
    );
  }

  static const Color successColor = Color(0xFF4CAF50);
  static const Color warningColor = Color(0xFFFF9800);
  static const Color infoColor = Color(0xFF2196F3);
}
