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
