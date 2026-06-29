import 'package:freezed_annotation/freezed_annotation.dart';

part 'membro_model.freezed.dart';
part 'membro_model.g.dart';

enum MembroStatus { ativo, pendente }

@freezed
abstract class MembroModel with _$MembroModel {
  const factory MembroModel({
    required String userId,
    required String nome,
    required String cargo,
    String? fotoUrl,
    @Default(MembroStatus.ativo) MembroStatus status,
  }) = _MembroModel;

  factory MembroModel.fromJson(Map<String, dynamic> json) =>
      _$MembroModelFromJson(json);
}
