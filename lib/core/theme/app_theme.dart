import 'package:flutter/material.dart';

/// Tokens de design partagés entre tous les écrans.
/// Reprend le style de l'app soignant (cohérence visuelle).
class AppColors {
  static const Color background    = Color(0xFF0A0A0F);
  static const Color card          = Color(0xFF12121A);
  static const Color border        = Color(0xFF1E1E2A);
  static const Color accent        = Color(0xFFFF4433);
  static const Color textPrimary   = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // white70
  static const Color textTertiary  = Color(0xFF6B6B7B);
  static const Color success       = Color(0xFF4CAF50);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        // Typo un peu plus grande que la moyenne car nos patients
        // sont souvent âgés. C'est volontaire.
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16, color: AppColors.textPrimary),
          bodyLarge:  TextStyle(fontSize: 18, color: AppColors.textPrimary),
        ),
        colorScheme: const ColorScheme.dark(
          primary:    AppColors.accent,
          onPrimary:  Colors.white,
          surface:    AppColors.card,
          onSurface:  AppColors.textPrimary,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );
}

/// Décoration de champ texte réutilisable
InputDecoration appInputDecoration({
  required String hint,
  required IconData icon,
  Widget? suffix,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
    prefixIcon: Icon(icon, color: AppColors.textTertiary),
    suffixIcon: suffix,
    filled: true,
    fillColor: AppColors.card,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.accent, width: 2),
    ),
  );
}
