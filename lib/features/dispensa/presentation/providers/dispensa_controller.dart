import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/pantry_item.dart';
import 'dispensa_provider.dart';

part 'dispensa_controller.g.dart';

@riverpod
class DispensaController extends _$DispensaController {
  @override
  FutureOr<void> build() {}

  Future<void> adicionarItem({
    required String casaId,
    required String nome,
    required String categoria,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).adicionarItem(
            casaId: casaId,
            nome: nome,
            categoria: categoria,
            userId: user.uid,
          ),
    );
  }

  Future<void> atualizarItem({
    required String casaId,
    required String itemId,
    required String nome,
    required String categoria,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).atualizarItem(
            casaId: casaId,
            itemId: itemId,
            nome: nome,
            categoria: categoria,
          ),
    );
  }

  Future<void> atualizarStatus({
    required String casaId,
    required String itemId,
    required ItemStatus statusAnterior,
    required ItemStatus novoStatus,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).atualizarStatus(
            casaId: casaId,
            itemId: itemId,
            statusAnterior: statusAnterior,
            novoStatus: novoStatus,
            userId: user.uid,
          ),
    );
  }

  Future<void> deletarItem({
    required String casaId,
    required String itemId,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).deletarItem(
            casaId: casaId,
            itemId: itemId,
          ),
    );
  }

  Future<void> atualizarDispensaEmLote({
    required String casaId,
    required List<String> itemIds,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null || itemIds.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).atualizarDispensaEmLote(
            casaId: casaId,
            itemIds: itemIds,
            userId: user.uid,
          ),
    );
  }
}
