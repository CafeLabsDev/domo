// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'casa_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CasaModel {

 String get id; String get nome; String get codigo; String get criadoPor;@TimestampConverter() DateTime get criadoEm;// Per-house display order for the (hardcoded) dispensa categories. Holds the
// existing category strings in the house's chosen order. When null/absent
// the client falls back to the hardcoded `kDispensaCategorias` order — this
// field is purely additive, no migration/backfill needed for existing
// houses. There is NO category CRUD: only the order is customizable.
 List<String>? get ordemCategorias;
/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CasaModelCopyWith<CasaModel> get copyWith => _$CasaModelCopyWithImpl<CasaModel>(this as CasaModel, _$identity);

  /// Serializes this CasaModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CasaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.criadoPor, criadoPor) || other.criadoPor == criadoPor)&&(identical(other.criadoEm, criadoEm) || other.criadoEm == criadoEm)&&const DeepCollectionEquality().equals(other.ordemCategorias, ordemCategorias));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nome,codigo,criadoPor,criadoEm,const DeepCollectionEquality().hash(ordemCategorias));

@override
String toString() {
  return 'CasaModel(id: $id, nome: $nome, codigo: $codigo, criadoPor: $criadoPor, criadoEm: $criadoEm, ordemCategorias: $ordemCategorias)';
}


}

/// @nodoc
abstract mixin class $CasaModelCopyWith<$Res>  {
  factory $CasaModelCopyWith(CasaModel value, $Res Function(CasaModel) _then) = _$CasaModelCopyWithImpl;
@useResult
$Res call({
 String id, String nome, String codigo, String criadoPor,@TimestampConverter() DateTime criadoEm, List<String>? ordemCategorias
});




}
/// @nodoc
class _$CasaModelCopyWithImpl<$Res>
    implements $CasaModelCopyWith<$Res> {
  _$CasaModelCopyWithImpl(this._self, this._then);

  final CasaModel _self;
  final $Res Function(CasaModel) _then;

/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? nome = null,Object? codigo = null,Object? criadoPor = null,Object? criadoEm = null,Object? ordemCategorias = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,criadoPor: null == criadoPor ? _self.criadoPor : criadoPor // ignore: cast_nullable_to_non_nullable
as String,criadoEm: null == criadoEm ? _self.criadoEm : criadoEm // ignore: cast_nullable_to_non_nullable
as DateTime,ordemCategorias: freezed == ordemCategorias ? _self.ordemCategorias : ordemCategorias // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}

}


/// Adds pattern-matching-related methods to [CasaModel].
extension CasaModelPatterns on CasaModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CasaModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CasaModel value)  $default,){
final _that = this;
switch (_that) {
case _CasaModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CasaModel value)?  $default,){
final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String nome,  String codigo,  String criadoPor, @TimestampConverter()  DateTime criadoEm,  List<String>? ordemCategorias)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
return $default(_that.id,_that.nome,_that.codigo,_that.criadoPor,_that.criadoEm,_that.ordemCategorias);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String nome,  String codigo,  String criadoPor, @TimestampConverter()  DateTime criadoEm,  List<String>? ordemCategorias)  $default,) {final _that = this;
switch (_that) {
case _CasaModel():
return $default(_that.id,_that.nome,_that.codigo,_that.criadoPor,_that.criadoEm,_that.ordemCategorias);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String nome,  String codigo,  String criadoPor, @TimestampConverter()  DateTime criadoEm,  List<String>? ordemCategorias)?  $default,) {final _that = this;
switch (_that) {
case _CasaModel() when $default != null:
return $default(_that.id,_that.nome,_that.codigo,_that.criadoPor,_that.criadoEm,_that.ordemCategorias);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CasaModel implements CasaModel {
  const _CasaModel({required this.id, required this.nome, required this.codigo, required this.criadoPor, @TimestampConverter() required this.criadoEm, final  List<String>? ordemCategorias}): _ordemCategorias = ordemCategorias;
  factory _CasaModel.fromJson(Map<String, dynamic> json) => _$CasaModelFromJson(json);

@override final  String id;
@override final  String nome;
@override final  String codigo;
@override final  String criadoPor;
@override@TimestampConverter() final  DateTime criadoEm;
// Per-house display order for the (hardcoded) dispensa categories. Holds the
// existing category strings in the house's chosen order. When null/absent
// the client falls back to the hardcoded `kDispensaCategorias` order — this
// field is purely additive, no migration/backfill needed for existing
// houses. There is NO category CRUD: only the order is customizable.
 final  List<String>? _ordemCategorias;
// Per-house display order for the (hardcoded) dispensa categories. Holds the
// existing category strings in the house's chosen order. When null/absent
// the client falls back to the hardcoded `kDispensaCategorias` order — this
// field is purely additive, no migration/backfill needed for existing
// houses. There is NO category CRUD: only the order is customizable.
@override List<String>? get ordemCategorias {
  final value = _ordemCategorias;
  if (value == null) return null;
  if (_ordemCategorias is EqualUnmodifiableListView) return _ordemCategorias;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CasaModelCopyWith<_CasaModel> get copyWith => __$CasaModelCopyWithImpl<_CasaModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CasaModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CasaModel&&(identical(other.id, id) || other.id == id)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.codigo, codigo) || other.codigo == codigo)&&(identical(other.criadoPor, criadoPor) || other.criadoPor == criadoPor)&&(identical(other.criadoEm, criadoEm) || other.criadoEm == criadoEm)&&const DeepCollectionEquality().equals(other._ordemCategorias, _ordemCategorias));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,nome,codigo,criadoPor,criadoEm,const DeepCollectionEquality().hash(_ordemCategorias));

@override
String toString() {
  return 'CasaModel(id: $id, nome: $nome, codigo: $codigo, criadoPor: $criadoPor, criadoEm: $criadoEm, ordemCategorias: $ordemCategorias)';
}


}

/// @nodoc
abstract mixin class _$CasaModelCopyWith<$Res> implements $CasaModelCopyWith<$Res> {
  factory _$CasaModelCopyWith(_CasaModel value, $Res Function(_CasaModel) _then) = __$CasaModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String nome, String codigo, String criadoPor,@TimestampConverter() DateTime criadoEm, List<String>? ordemCategorias
});




}
/// @nodoc
class __$CasaModelCopyWithImpl<$Res>
    implements _$CasaModelCopyWith<$Res> {
  __$CasaModelCopyWithImpl(this._self, this._then);

  final _CasaModel _self;
  final $Res Function(_CasaModel) _then;

/// Create a copy of CasaModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? nome = null,Object? codigo = null,Object? criadoPor = null,Object? criadoEm = null,Object? ordemCategorias = freezed,}) {
  return _then(_CasaModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,codigo: null == codigo ? _self.codigo : codigo // ignore: cast_nullable_to_non_nullable
as String,criadoPor: null == criadoPor ? _self.criadoPor : criadoPor // ignore: cast_nullable_to_non_nullable
as String,criadoEm: null == criadoEm ? _self.criadoEm : criadoEm // ignore: cast_nullable_to_non_nullable
as DateTime,ordemCategorias: freezed == ordemCategorias ? _self._ordemCategorias : ordemCategorias // ignore: cast_nullable_to_non_nullable
as List<String>?,
  ));
}


}

// dart format on
