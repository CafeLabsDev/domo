// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'membro_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MembroModel {

 String get userId; String get nome; String get cargo; String? get fotoUrl; MembroStatus get status;
/// Create a copy of MembroModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MembroModelCopyWith<MembroModel> get copyWith => _$MembroModelCopyWithImpl<MembroModel>(this as MembroModel, _$identity);

  /// Serializes this MembroModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MembroModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.cargo, cargo) || other.cargo == cargo)&&(identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,nome,cargo,fotoUrl,status);

@override
String toString() {
  return 'MembroModel(userId: $userId, nome: $nome, cargo: $cargo, fotoUrl: $fotoUrl, status: $status)';
}


}

/// @nodoc
abstract mixin class $MembroModelCopyWith<$Res>  {
  factory $MembroModelCopyWith(MembroModel value, $Res Function(MembroModel) _then) = _$MembroModelCopyWithImpl;
@useResult
$Res call({
 String userId, String nome, String cargo, String? fotoUrl, MembroStatus status
});




}
/// @nodoc
class _$MembroModelCopyWithImpl<$Res>
    implements $MembroModelCopyWith<$Res> {
  _$MembroModelCopyWithImpl(this._self, this._then);

  final MembroModel _self;
  final $Res Function(MembroModel) _then;

/// Create a copy of MembroModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? nome = null,Object? cargo = null,Object? fotoUrl = freezed,Object? status = null,}) {
  return _then(_self.copyWith(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,cargo: null == cargo ? _self.cargo : cargo // ignore: cast_nullable_to_non_nullable
as String,fotoUrl: freezed == fotoUrl ? _self.fotoUrl : fotoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembroStatus,
  ));
}

}


/// Adds pattern-matching-related methods to [MembroModel].
extension MembroModelPatterns on MembroModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MembroModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MembroModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MembroModel value)  $default,){
final _that = this;
switch (_that) {
case _MembroModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MembroModel value)?  $default,){
final _that = this;
switch (_that) {
case _MembroModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  String nome,  String cargo,  String? fotoUrl,  MembroStatus status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MembroModel() when $default != null:
return $default(_that.userId,_that.nome,_that.cargo,_that.fotoUrl,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  String nome,  String cargo,  String? fotoUrl,  MembroStatus status)  $default,) {final _that = this;
switch (_that) {
case _MembroModel():
return $default(_that.userId,_that.nome,_that.cargo,_that.fotoUrl,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  String nome,  String cargo,  String? fotoUrl,  MembroStatus status)?  $default,) {final _that = this;
switch (_that) {
case _MembroModel() when $default != null:
return $default(_that.userId,_that.nome,_that.cargo,_that.fotoUrl,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MembroModel implements MembroModel {
  const _MembroModel({required this.userId, required this.nome, required this.cargo, this.fotoUrl, this.status = MembroStatus.ativo});
  factory _MembroModel.fromJson(Map<String, dynamic> json) => _$MembroModelFromJson(json);

@override final  String userId;
@override final  String nome;
@override final  String cargo;
@override final  String? fotoUrl;
@override@JsonKey() final  MembroStatus status;

/// Create a copy of MembroModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MembroModelCopyWith<_MembroModel> get copyWith => __$MembroModelCopyWithImpl<_MembroModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MembroModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MembroModel&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.nome, nome) || other.nome == nome)&&(identical(other.cargo, cargo) || other.cargo == cargo)&&(identical(other.fotoUrl, fotoUrl) || other.fotoUrl == fotoUrl)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,nome,cargo,fotoUrl,status);

@override
String toString() {
  return 'MembroModel(userId: $userId, nome: $nome, cargo: $cargo, fotoUrl: $fotoUrl, status: $status)';
}


}

/// @nodoc
abstract mixin class _$MembroModelCopyWith<$Res> implements $MembroModelCopyWith<$Res> {
  factory _$MembroModelCopyWith(_MembroModel value, $Res Function(_MembroModel) _then) = __$MembroModelCopyWithImpl;
@override @useResult
$Res call({
 String userId, String nome, String cargo, String? fotoUrl, MembroStatus status
});




}
/// @nodoc
class __$MembroModelCopyWithImpl<$Res>
    implements _$MembroModelCopyWith<$Res> {
  __$MembroModelCopyWithImpl(this._self, this._then);

  final _MembroModel _self;
  final $Res Function(_MembroModel) _then;

/// Create a copy of MembroModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? nome = null,Object? cargo = null,Object? fotoUrl = freezed,Object? status = null,}) {
  return _then(_MembroModel(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,nome: null == nome ? _self.nome : nome // ignore: cast_nullable_to_non_nullable
as String,cargo: null == cargo ? _self.cargo : cargo // ignore: cast_nullable_to_non_nullable
as String,fotoUrl: freezed == fotoUrl ? _self.fotoUrl : fotoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MembroStatus,
  ));
}


}

// dart format on
