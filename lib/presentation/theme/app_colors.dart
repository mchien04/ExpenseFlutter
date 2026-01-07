import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary Colors
  static const Color primaryLight = Color(0xFF6750A4);
  static const Color primaryDark = Color(0xFFD0BCFF);

  // Income Colors (Xanh)
  static const Color income = Color(0xFF4CAF50);
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color incomeDark = Color(0xFF2E7D32);

  // Expense Colors (Đỏ)
  static const Color expense = Color(0xFFF44336);
  static const Color expenseLight = Color(0xFFFFEBEE);
  static const Color expenseDark = Color(0xFFC62828);

  // Neutral Colors
  static const Color backgroundLight = Color(0xFFFFFBFE);
  static const Color backgroundDark = Color(0xFF1C1B1F);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF2B2930);
  static const Color cardLight = Color(0xFFF7F2FA);
  static const Color cardDark = Color(0xFF36343B);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF1C1B1F);
  static const Color textPrimaryDark = Color(0xFFE6E1E5);
  static const Color textSecondaryLight = Color(0xFF49454F);
  static const Color textSecondaryDark = Color(0xFFCAC4D0);

  // Chart Colors
  static const List<Color> chartColors = [
    Color(0xFF6750A4),
    Color(0xFF03DAC6),
    Color(0xFFFF9800),
    Color(0xFF2196F3),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF4CAF50),
    Color(0xFFFF5722),
  ];

  // Gradient
  static const LinearGradient incomeGradient = LinearGradient(
    colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient expenseGradient = LinearGradient(
    colors: [Color(0xFFF44336), Color(0xFFE57373)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6750A4), Color(0xFF9575CD)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
