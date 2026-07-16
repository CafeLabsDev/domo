abstract final class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  // Border radius (generic scale — kept for spots not covered by the
  // dedicated "Armário Aberto" component radii below, e.g. bottom-sheet
  // top corners, the invite-code container in casa_page.dart).
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusFull = 100.0;

  // "Armário Aberto" identity — dedicated component radii (see
  // docs/DESIGN.md §3). Buttons deliberately keep `radiusMd` above
  // (M3 default pill shape, unchanged by design).
  static const double radiusCard = 10.0;
  static const double radiusInput = 8.0;
  static const double radiusChip = 6.0;

  // Icon sizes
  static const double iconSm = 18.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
}
