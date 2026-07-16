import 'package:flutter/material.dart';

/// "Armário Aberto" identity tokens — see `docs/DESIGN.md` for the full
/// rationale and the WCAG contrast ratios behind every pairing below.
///
/// Values that are already representable as a `ColorScheme` slot (primary,
/// secondary, tertiary, error, surface, outline, containers...) are wired
/// into [AppTheme]'s `ColorScheme` and should normally be read from
/// `Theme.of(context).colorScheme` in widgets, not from here directly.
/// This class exists for the tokens `ColorScheme` has no slot for: the
/// status family (Tem/Em falta/No carrinho), the three-tier "ink" hierarchy
/// where the extra nuance matters (only `inkSubtle` needs direct access —
/// `inkPrimary`/`inkSecondary` are wired to `onSurface`/`onSurfaceVariant`),
/// and the member-color palette.
abstract final class AppColors {
  // --- Light theme ---
  static const primaryLight = Color(0xFF2C4A7C); // Azul Louça
  static const onPrimaryLight = Color(0xFFFFFFFF);
  static const primaryContainerLight = Color(0xFFD7E1F0);
  static const onPrimaryContainerLight = Color(0xFF16233D);

  static const secondaryLight = Color(0xFF63584A); // Grafite Quente
  static const onSecondaryLight = Color(0xFFFFFFFF);
  static const secondaryContainerLight = Color(0xFFF0E4D0);
  static const onSecondaryContainerLight = Color(0xFF4A3A22);

  static const tertiaryLight = Color(0xFF8A5F12); // Mostarda
  static const onTertiaryLight = Color(0xFFFFFFFF);
  static const tertiaryContainerLight = Color(0xFFF4E7C8);
  static const onTertiaryContainerLight = Color(0xFF3E2E10);

  static const errorLight = Color(0xFFB83A2A);
  static const onErrorLight = Color(0xFFFFFFFF);
  static const errorContainerLight = Color(0xFFF9DCD6);
  static const onErrorContainerLight = Color(0xFF5A2318);

  static const backgroundLight = Color(0xFFEEF1F1); // "ceramic stone" canvas
  static const surfaceLight = Color(0xFFFFFFFF); // "glaze" — cards, rows
  static const surfaceElevatedLight = Color(0xFFFFFFFF); // dialogs/sheets

  static const inkPrimaryLight = Color(0xFF1B2024);
  static const inkSecondaryLight = Color(0xFF4F5A61);
  static const inkSubtleLight = Color(0xFF5A6469);
  static const outlineLight = Color(0xFF5C6B78);
  static const dividerLight = Color(0x1F1B2024); // inkPrimary @ 12%

  static const statusTemLight = Color(0xFF286B5C); // Verde Jade
  static const statusFaltaLight = errorLight;
  static const statusCarrinhoLight = tertiaryLight;

  static const statusTemContainerLight = Color(0xFFD9EDE7);
  static const onStatusTemContainerLight = Color(0xFF124338);
  static const statusFaltaContainerLight = errorContainerLight;
  static const onStatusFaltaContainerLight = onErrorContainerLight;
  static const statusCarrinhoContainerLight = tertiaryContainerLight;
  static const onStatusCarrinhoContainerLight = onTertiaryContainerLight;

  // --- Dark theme ---
  static const primaryDark = Color(0xFF9BB8DE);
  static const onPrimaryDark = Color(0xFF16233D);
  static const primaryContainerDark = Color(0xFF223A61);
  static const onPrimaryContainerDark = Color(0xFFC9D9F0);

  static const secondaryDark = Color(0xFFC9BBA8);
  static const onSecondaryDark = Color(0xFF3A2F22);
  static const secondaryContainerDark = Color(0xFF3F362B);
  static const onSecondaryContainerDark = Color(0xFFE8DEC9);

  static const tertiaryDark = Color(0xFFE0B84A);
  static const onTertiaryDark = Color(0xFF3E2E10);
  static const tertiaryContainerDark = Color(0xFF4A3A14);
  static const onTertiaryContainerDark = Color(0xFFF4E0A8);

  static const errorDark = Color(0xFFE8897A);
  static const onErrorDark = Color(0xFF4A160E);
  static const errorContainerDark = Color(0xFF4A1B14);
  static const onErrorContainerDark = Color(0xFFF7CFC5);

  static const backgroundDark = Color(0xFF12171C);
  static const surfaceDark = Color(0xFF1B2128);
  static const surfaceElevatedDark = Color(0xFF222932);

  static const inkPrimaryDark = Color(0xFFEDEFF1);
  static const inkSecondaryDark = Color(0xFFB9C1C7);
  static const inkSubtleDark = Color(0xFF8F9AA1);
  static const outlineDark = Color(0xFF8D9AA6);
  static const dividerDark = Color(0x1FEDEFF1); // inkPrimary @ 12%

  static const statusTemDark = Color(0xFF6FC2AC);
  static const statusFaltaDark = errorDark;
  static const statusCarrinhoDark = tertiaryDark;

  static const statusTemContainerDark = Color(0xFF163F35);
  static const onStatusTemContainerDark = Color(0xFFBEE8DD);
  static const statusFaltaContainerDark = errorContainerDark;
  static const onStatusFaltaContainerDark = onErrorContainerDark;
  static const statusCarrinhoContainerDark = tertiaryContainerDark;
  static const onStatusCarrinhoContainerDark = onTertiaryContainerDark;

  // --- Member colors (§1.3 — deterministic per userId, avatar identity) ---
  // (background, onText) pairs, light then dark, same hue order for both.
  static const List<(Color, Color)> memberColorsLight = [
    (primaryLight, Color(0xFFFFFFFF)), // 1 Azul Louça
    (tertiaryLight, Color(0xFFFFFFFF)), // 2 Mostarda
    (statusTemLight, Color(0xFFFFFFFF)), // 3 Verde Jade
    (Color(0xFF6B4A73), Color(0xFFFFFFFF)), // 4 Ameixa
    (secondaryLight, Color(0xFFFFFFFF)), // 5 Grafite Quente
    (Color(0xFFA15A34), Color(0xFFFFFFFF)), // 6 Argila
  ];

  static const List<(Color, Color)> memberColorsDark = [
    (primaryDark, Color(0xFF16233D)),
    (tertiaryDark, Color(0xFF3E2E10)),
    (statusTemDark, Color(0xFF0B2C24)),
    (Color(0xFFC9A0CE), Color(0xFF3A1B40)),
    (secondaryDark, Color(0xFF3A2F22)),
    (Color(0xFFDDA275), Color(0xFF4A2410)),
  ];

  /// Deterministic member color assignment: hash of [userId] modulo 6 (§1.3
  /// — not user-pickable in v1). Returns `(background, onText)`.
  static (Color, Color) memberColorFor(String userId, Brightness brightness) {
    final palette =
        brightness == Brightness.dark ? memberColorsDark : memberColorsLight;
    final index = userId.hashCode.abs() % palette.length;
    return palette[index];
  }
}
