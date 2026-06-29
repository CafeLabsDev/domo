import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pantry_item.freezed.dart';
part 'pantry_item.g.dart';

@JsonEnum(fieldRename: FieldRename.snake)
enum ItemStatus {
  tem,
  naoTem,
  noCarrinho;

  String get label => switch (this) {
        tem => 'Temos',
        naoTem => 'Falta',
        noCarrinho => 'No carrinho',
      };

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
  const factory PantryItem({
    required String id,
    required String casaId,
    required String nome,
    required String categoria,
    required ItemStatus status,
    @_TimestampConverter() required DateTime atualizadoEm,
    required String atualizadoPor,
  }) = _PantryItem;

  factory PantryItem.fromJson(Map<String, dynamic> json) =>
      _$PantryItemFromJson(json);
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
