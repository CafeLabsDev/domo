import '../../../l10n/app_localizations.dart';

// Fixed, Portuguese-only identifiers — these are the actual values stored in
// Firestore (`item.categoria`, `casa.ordemCategorias`), not display copy.
// Changing them would be a data migration, not a translation. Use
// `categoriaLabel` below to get the localized text shown in the UI.
const kDispensaCategorias = [
  'Frutas e Verduras',
  'Laticínios',
  'Carnes e Peixes',
  'Padaria',
  'Bebidas',
  'Limpeza',
  'Higiene e Cuidados',
  'Outros',
];

/// Localized display label for a fixed category key. Falls back to the raw
/// key itself for anything unrecognized (defensive, shouldn't happen since
/// the key set is closed).
String categoriaLabel(AppLocalizations l10n, String categoria) {
  return switch (categoria) {
    'Frutas e Verduras' => l10n.categoryFrutasVerduras,
    'Laticínios' => l10n.categoryLaticinios,
    'Carnes e Peixes' => l10n.categoryCarnesPeixes,
    'Padaria' => l10n.categoryPadaria,
    'Bebidas' => l10n.categoryBebidas,
    'Limpeza' => l10n.categoryLimpeza,
    'Higiene e Cuidados' => l10n.categoryHigieneCuidados,
    'Outros' => l10n.categoryOutros,
    _ => categoria,
  };
}

/// Resolves the display order of the (fixed) dispensa categories for a house:
/// the house's saved [ordemCategorias] when present, falling back to the
/// hardcoded [kDispensaCategorias] order when null/empty (feature 3 — see
/// `CasaModel.ordemCategorias`). Defensive against stale saved orders: any
/// unknown string in [ordemCategorias] is dropped, and any known category
/// missing from it (e.g. because `kDispensaCategorias` grew after the house
/// last saved a custom order) is appended at the end in the fixed list's
/// order — so this never silently hides a category from the grouped views.
List<String> categoriasOrdenadas(List<String>? ordemCategorias) {
  if (ordemCategorias == null || ordemCategorias.isEmpty) {
    return kDispensaCategorias;
  }
  final known =
      ordemCategorias.where(kDispensaCategorias.contains).toList();
  final faltando =
      kDispensaCategorias.where((c) => !known.contains(c));
  return [...known, ...faltando];
}
