import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'casa_model.freezed.dart';
part 'casa_model.g.dart';

@freezed
abstract class CasaModel with _$CasaModel {
  const factory CasaModel({
    required String id,
    required String nome,
    required String codigo,
    required String criadoPor,
    @TimestampConverter() required DateTime criadoEm,
    // Per-house display order for the (hardcoded) dispensa categories. Holds the
    // existing category strings in the house's chosen order. When null/absent
    // the client falls back to the hardcoded `kDispensaCategorias` order — this
    // field is purely additive, no migration/backfill needed for existing
    // houses. There is NO category CRUD: only the order is customizable.
    List<String>? ordemCategorias,
  }) = _CasaModel;

  factory CasaModel.fromJson(Map<String, dynamic> json) =>
      _$CasaModelFromJson(json);
}

class TimestampConverter implements JsonConverter<DateTime, dynamic> {
  const TimestampConverter();

  @override
  DateTime fromJson(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  @override
  Timestamp toJson(DateTime date) => Timestamp.fromDate(date);
}
