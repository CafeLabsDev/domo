// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pantry_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PantryItem _$PantryItemFromJson(Map<String, dynamic> json) => _PantryItem(
  id: json['id'] as String,
  casaId: json['casaId'] as String,
  nome: json['nome'] as String,
  categoria: json['categoria'] as String,
  status: $enumDecode(_$ItemStatusEnumMap, json['status']),
  atualizadoEm: const _TimestampConverter().fromJson(json['atualizadoEm']),
  atualizadoPor: json['atualizadoPor'] as String,
  controlaEstoque: json['controlaEstoque'] as bool? ?? false,
  quantidade: (json['quantidade'] as num?)?.toInt(),
  estoqueMinimo: (json['estoqueMinimo'] as num?)?.toInt(),
  noCarrinho: json['noCarrinho'] as bool? ?? false,
);

Map<String, dynamic> _$PantryItemToJson(_PantryItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'casaId': instance.casaId,
      'nome': instance.nome,
      'categoria': instance.categoria,
      'status': _$ItemStatusEnumMap[instance.status]!,
      'atualizadoEm': const _TimestampConverter().toJson(instance.atualizadoEm),
      'atualizadoPor': instance.atualizadoPor,
      'controlaEstoque': instance.controlaEstoque,
      'quantidade': instance.quantidade,
      'estoqueMinimo': instance.estoqueMinimo,
      'noCarrinho': instance.noCarrinho,
    };

const _$ItemStatusEnumMap = {
  ItemStatus.tem: 'tem',
  ItemStatus.naoTem: 'nao_tem',
  ItemStatus.noCarrinho: 'no_carrinho',
};
