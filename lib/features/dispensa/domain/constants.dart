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
