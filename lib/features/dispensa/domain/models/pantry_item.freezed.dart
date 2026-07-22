// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pantry_item.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PantryItem {

 String get id; String get casaId; String get nome; String get categoria; ItemStatus get status;@_TimestampConverter() DateTime get atualizadoEm; String get atualizadoPor;// ---- optional quantity + minimum-stock control (opt-in, default off) ----
// When `controlaEstoque` is true, `status` is DERIVED from
// quantidade <= estoqueMinimo (=> naoTem, else tem) and is never marked
// manually; the shopping-cart state is carried by `noCarrinho` instead of
// the status enum. When false (or absent, for pre-existing items) the item
// behaves EXACTLY as before: manual 3-value `status`, cart = noCarrinho.
 bool get controlaEstoque; int? get quantidade; int? get estoqueMinimo; bool get noCarrinho;
/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PantryItemCopyWith<PantryItem> get copyWith => _$PantryItemCopyWithImpl<PantryItem>(this as PantryItem, _$identity);

  /// Serializes this PantryItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PantryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.casaId, casaId) || other.casaId == casaId)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.status, status) || other.status == status)&&(identical(other.atualizadoEm, atualizadoEm) || other.atualizadoEm == atualizadoEm)&&(identical(other.atualizadoPor, atualizadoPor) || other.atualizadoPor == atualizadoPor)&&(identical(other.controlaEstoque, controlaEstoque) || other.controlaEstoque == controlaEstoque)&&(identical(other.quantidade, quantidade) || other.quantidade == quantidade)&&(identical(other.estoqueMinimo, estoqueMinimo) || other.estoqueMinimo == estoqueMinimo)&&(identical(other.noCarrinho, noCarrinho) || other.noCarrinho == noCarrinho));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,casaId,nome,categoria,status,atualizadoEm,atualizadoPor,controlaEstoque,quantidade,estoqueMinimo,noCarrinho);

@override
String toString() {
  return 'PantryItem(id: $id, casaId: $casaId, nome: $nome, categoria: $categoria, status: $status, atualizadoEm: $atualizadoEm, atualizadoPor: $atualizadoPor, controlaEstoque: $controlaEstoque, quantidade: $quantidade, estoqueMinimo: $estoqueMinimo, noCarrinho: $noCarrinho)';
}


}

/// @nodoc
abstract mixin class $PantryItemCopyWith<$Res>  {
  factory $PantryItemCopyWith(PantryItem value, $Res Function(PantryItem) _then) = _$PantryItemCopyWithImpl;
@useResult
$Res call({
 String id, String casaId, String nome, String categoria, ItemStatus status,@_TimestampConverter() DateTime atualizadoEm, String atualizadoPor, bool controlaEstoque, int? quantidade, int? estoqueMinimo, bool noCarrinho
});




}
/// @nodoc
class _$PantryItemCopyWithImpl<$Res>
    implements $PantryItemCopyWith<$Res> {
  _$PantryItemCopyWithImpl(this._self, this._then);

  final PantryItem _self;
  final $Res Function(PantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? casaId = null,Object? nome = null,Object? categoria = null,Object? status = null,Object? atualizadoEm = null,Object? atualizadoPor = null,Object? controlaEstoque = null,Object? quantidade = freezed,Object? estoqueMinimo = freezed,Object? noCarrinho = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,casaId: null == casaId ? _self.casaId : casaId // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,atualizadoEm: null == atualizadoEm ? _self.atualizadoEm : atualizadoEm // ignore: cast_nullable_to_non_nullable
as DateTime,atualizadoPor: null == atualizadoPor ? _self.atualizadoPor : atualizadoPor // ignore: cast_nullable_to_non_nullable
as String,controlaEstoque: null == controlaEstoque ? _self.controlaEstoque : controlaEstoque // ignore: cast_nullable_to_non_nullable
as bool,quantidade: freezed == quantidade ? _self.quantidade : quantidade // ignore: cast_nullable_to_non_nullable
as int?,estoqueMinimo: freezed == estoqueMinimo ? _self.estoqueMinimo : estoqueMinimo // ignore: cast_nullable_to_non_nullable
as int?,noCarrinho: null == noCarrinho ? _self.noCarrinho : noCarrinho // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [PantryItem].
extension PantryItemPatterns on PantryItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PantryItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PantryItem value)  $default,){
final _that = this;
switch (_that) {
case _PantryItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PantryItem value)?  $default,){
final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String casaId,  String nome,  String categoria,  ItemStatus status, @_TimestampConverter()  DateTime atualizadoEm,  String atualizadoPor,  bool controlaEstoque,  int? quantidade,  int? estoqueMinimo,  bool noCarrinho)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
return $default(_that.id,_that.casaId,_that.nome,_that.categoria,_that.status,_that.atualizadoEm,_that.atualizadoPor,_that.controlaEstoque,_that.quantidade,_that.estoqueMinimo,_that.noCarrinho);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String casaId,  String nome,  String categoria,  ItemStatus status, @_TimestampConverter()  DateTime atualizadoEm,  String atualizadoPor,  bool controlaEstoque,  int? quantidade,  int? estoqueMinimo,  bool noCarrinho)  $default,) {final _that = this;
switch (_that) {
case _PantryItem():
return $default(_that.id,_that.casaId,_that.nome,_that.categoria,_that.status,_that.atualizadoEm,_that.atualizadoPor,_that.controlaEstoque,_that.quantidade,_that.estoqueMinimo,_that.noCarrinho);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String casaId,  String nome,  String categoria,  ItemStatus status, @_TimestampConverter()  DateTime atualizadoEm,  String atualizadoPor,  bool controlaEstoque,  int? quantidade,  int? estoqueMinimo,  bool noCarrinho)?  $default,) {final _that = this;
switch (_that) {
case _PantryItem() when $default != null:
return $default(_that.id,_that.casaId,_that.nome,_that.categoria,_that.status,_that.atualizadoEm,_that.atualizadoPor,_that.controlaEstoque,_that.quantidade,_that.estoqueMinimo,_that.noCarrinho);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PantryItem extends PantryItem {
  const _PantryItem({required this.id, required this.casaId, required this.nome, required this.categoria, required this.status, @_TimestampConverter() required this.atualizadoEm, required this.atualizadoPor, this.controlaEstoque = false, this.quantidade, this.estoqueMinimo, this.noCarrinho = false}): super._();
  factory _PantryItem.fromJson(Map<String, dynamic> json) => _$PantryItemFromJson(json);

@override final  String id;
@override final  String casaId;
@override final  String nome;
@override final  String categoria;
@override final  ItemStatus status;
@override@_TimestampConverter() final  DateTime atualizadoEm;
@override final  String atualizadoPor;
// ---- optional quantity + minimum-stock control (opt-in, default off) ----
// When `controlaEstoque` is true, `status` is DERIVED from
// quantidade <= estoqueMinimo (=> naoTem, else tem) and is never marked
// manually; the shopping-cart state is carried by `noCarrinho` instead of
// the status enum. When false (or absent, for pre-existing items) the item
// behaves EXACTLY as before: manual 3-value `status`, cart = noCarrinho.
@override@JsonKey() final  bool controlaEstoque;
@override final  int? quantidade;
@override final  int? estoqueMinimo;
@override@JsonKey() final  bool noCarrinho;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PantryItemCopyWith<_PantryItem> get copyWith => __$PantryItemCopyWithImpl<_PantryItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PantryItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PantryItem&&(identical(other.id, id) || other.id == id)&&(identical(other.casaId, casaId) || other.casaId == casaId)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.categoria, categoria) || other.categoria == categoria)&&(identical(other.status, status) || other.status == status)&&(identical(other.atualizadoEm, atualizadoEm) || other.atualizadoEm == atualizadoEm)&&(identical(other.atualizadoPor, atualizadoPor) || other.atualizadoPor == atualizadoPor)&&(identical(other.controlaEstoque, controlaEstoque) || other.controlaEstoque == controlaEstoque)&&(identical(other.quantidade, quantidade) || other.quantidade == quantidade)&&(identical(other.estoqueMinimo, estoqueMinimo) || other.estoqueMinimo == estoqueMinimo)&&(identical(other.noCarrinho, noCarrinho) || other.noCarrinho == noCarrinho));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,casaId,nome,categoria,status,atualizadoEm,atualizadoPor,controlaEstoque,quantidade,estoqueMinimo,noCarrinho);

@override
String toString() {
  return 'PantryItem(id: $id, casaId: $casaId, nome: $nome, categoria: $categoria, status: $status, atualizadoEm: $atualizadoEm, atualizadoPor: $atualizadoPor, controlaEstoque: $controlaEstoque, quantidade: $quantidade, estoqueMinimo: $estoqueMinimo, noCarrinho: $noCarrinho)';
}


}

/// @nodoc
abstract mixin class _$PantryItemCopyWith<$Res> implements $PantryItemCopyWith<$Res> {
  factory _$PantryItemCopyWith(_PantryItem value, $Res Function(_PantryItem) _then) = __$PantryItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String casaId, String nome, String categoria, ItemStatus status,@_TimestampConverter() DateTime atualizadoEm, String atualizadoPor, bool controlaEstoque, int? quantidade, int? estoqueMinimo, bool noCarrinho
});




}
/// @nodoc
class __$PantryItemCopyWithImpl<$Res>
    implements _$PantryItemCopyWith<$Res> {
  __$PantryItemCopyWithImpl(this._self, this._then);

  final _PantryItem _self;
  final $Res Function(_PantryItem) _then;

/// Create a copy of PantryItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? casaId = null,Object? nome = null,Object? categoria = null,Object? status = null,Object? atualizadoEm = null,Object? atualizadoPor = null,Object? controlaEstoque = null,Object? quantidade = freezed,Object? estoqueMinimo = freezed,Object? noCarrinho = null,}) {
  return _then(_PantryItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,casaId: null == casaId ? _self.casaId : casaId // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,categoria: null == categoria ? _self.categoria : categoria // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ItemStatus,atualizadoEm: null == atualizadoEm ? _self.atualizadoEm : atualizadoEm // ignore: cast_nullable_to_non_nullable
as DateTime,atualizadoPor: null == atualizadoPor ? _self.atualizadoPor : atualizadoPor // ignore: cast_nullable_to_non_nullable
as String,controlaEstoque: null == controlaEstoque ? _self.controlaEstoque : controlaEstoque // ignore: cast_nullable_to_non_nullable
as bool,quantidade: freezed == quantidade ? _self.quantidade : quantidade // ignore: cast_nullable_to_non_nullable
as int?,estoqueMinimo: freezed == estoqueMinimo ? _self.estoqueMinimo : estoqueMinimo // ignore: cast_nullable_to_non_nullable
as int?,noCarrinho: null == noCarrinho ? _self.noCarrinho : noCarrinho // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
