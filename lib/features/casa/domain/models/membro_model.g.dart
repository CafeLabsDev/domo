// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membro_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_MembroModel _$MembroModelFromJson(Map<String, dynamic> json) => _MembroModel(
  userId: json['userId'] as String,
  nome: json['nome'] as String,
  cargo: json['cargo'] as String,
  fotoUrl: json['fotoUrl'] as String?,
  status:
      $enumDecodeNullable(_$MembroStatusEnumMap, json['status']) ??
      MembroStatus.ativo,
);

Map<String, dynamic> _$MembroModelToJson(_MembroModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'nome': instance.nome,
      'cargo': instance.cargo,
      'fotoUrl': instance.fotoUrl,
      'status': _$MembroStatusEnumMap[instance.status]!,
    };

const _$MembroStatusEnumMap = {
  MembroStatus.ativo: 'ativo',
  MembroStatus.pendente: 'pendente',
};
