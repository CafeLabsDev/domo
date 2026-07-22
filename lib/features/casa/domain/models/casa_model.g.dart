// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'casa_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CasaModel _$CasaModelFromJson(Map<String, dynamic> json) => _CasaModel(
  id: json['id'] as String,
  nome: json['nome'] as String,
  codigo: json['codigo'] as String,
  criadoPor: json['criadoPor'] as String,
  criadoEm: const TimestampConverter().fromJson(json['criadoEm']),
  ordemCategorias: (json['ordemCategorias'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
);

Map<String, dynamic> _$CasaModelToJson(_CasaModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'nome': instance.nome,
      'codigo': instance.codigo,
      'criadoPor': instance.criadoPor,
      'criadoEm': const TimestampConverter().toJson(instance.criadoEm),
      'ordemCategorias': instance.ordemCategorias,
    };
