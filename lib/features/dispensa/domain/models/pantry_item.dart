import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_item.freezed.dart';
part 'pantry_item.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ItemStatus {
  tem,
  naoTem,
  noCarrinho;

  ItemStatus get next => switch (this) {
        tem => naoTem,
        naoTem => noCarrinho,
        noCarrinho => tem,
      };

  String get firestoreValue => switch (this) {
        tem => 'tem',
        naoTem => 'nao_tem',
        noCarrinho => 'no_carrinho',
      };
}

@freezed
abstract class PantryItem with _$PantryItem {
  const PantryItem._();

  const factory PantryItem({
    required String id,
    required String casaId,
    required String nome,
    required String categoria,
    required ItemStatus status,
    @_TimestampConverter() required DateTime atualizadoEm,
    required String atualizadoPor,
    // ---- optional quantity + minimum-stock control (opt-in, default off) ----
    // When `controlaEstoque` is true, `status` is DERIVED from
    // quantidade <= estoqueMinimo (=> naoTem, else tem) and is never marked
    // manually; the shopping-cart state is carried by `noCarrinho` instead of
    // the status enum. When false (or absent, for pre-existing items) the item
    // behaves EXACTLY as before: manual 3-value `status`, cart = noCarrinho.
    @Default(false) bool controlaEstoque,
    int? quantidade,
    int? estoqueMinimo,
    @Default(false) bool noCarrinho,
  }) = _PantryItem;

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);

  /// Stock status derived from quantity: at/below the minimum => "falta".
  /// Single source of the ON-mode derivation rule, shared by the repository
  /// writes and the presentation layer so both stay consistent with the
  /// Firestore rule that pins the stored `status`.
  static ItemStatus statusPorQuantidade(int quantidade, int estoqueMinimo) =>
      quantidade <= estoqueMinimo ? ItemStatus.naoTem : ItemStatus.tem;

  /// Unified "is this item currently in the shopping cart" for BOTH modes, so
  /// the Mercado view does not have to branch on the mode: ON-mode uses the
  /// orthogonal `noCarrinho` flag; OFF-mode keeps the legacy `no_carrinho`
  /// status value.
  bool get estaNoCarrinho =>
      controlaEstoque ? noCarrinho : status == ItemStatus.noCarrinho;

  /// True when the item counts as "missing" for the shopping list. For ON-mode
  /// the stored `status` is already the derived value, so this holds for both
  /// modes.
  bool get emFalta => status == ItemStatus.naoTem;
}

class _TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const _TimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
