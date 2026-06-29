import 'package:flutter/material.dart';

abstract final class AppColors {
  // --- Sage Home Palette ---

  // Primary — Verde Sálvia
  static const primary = Color(0xFF4A7C59);
  static const primaryLight = Color(0xFF6B9E79);
  static const primaryDark = Color(0xFF2D5C3E);
  static const onPrimary = Color(0xFFFFFFFF);

  // Secondary — Lavanda
  static const secondary = Color(0xFF7D5BA6);
  static const secondaryLight = Color(0xFF9E7EC4);
  static const secondaryDark = Color(0xFF5C3D85);
  static const onSecondary = Color(0xFFFFFFFF);

  // Tertiary — Pêssego suave (highlights/accents quentes)
  static const tertiary = Color(0xFFE8A87C);
  static const onTertiary = Color(0xFF3B1F00);

  // Error
  static const error = Color(0xFFBA1A1A);
  static const onError = Color(0xFFFFFFFF);

  // --- Light Mode ---
  static const backgroundLight = Color(0xFFF8F5EF);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceVariantLight = Color(0xFFEEEAE2);
  static const onBackgroundLight = Color(0xFF1C1B18);
  static const onSurfaceLight = Color(0xFF1C1B18);
  static const onSurfaceVariantLight = Color(0xFF4A4740);
  static const outlineLight = Color(0xFF7B7870);

  // --- Dark Mode ---
  static const backgroundDark = Color(0xFF1A1C1E);
  static const surfaceDark = Color(0xFF2B2D30);
  static const surfaceVariantDark = Color(0xFF3A3C3F);
  static const onBackgroundDark = Color(0xFFE5E2DA);
  static const onSurfaceDark = Color(0xFFE5E2DA);
  static const onSurfaceVariantDark = Color(0xFFCBC8BF);
  static const outlineDark = Color(0xFF958F87);

  // --- Status colors (item da dispensa) ---
  static const statusHave = Color(0xFF4A7C59);
  static const statusNeed = Color(0xFFBA1A1A);
  static const statusInCart = Color(0xFFE8A87C);
}
