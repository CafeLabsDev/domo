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
    required List<PantryItem> itens,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null || itens.isEmpty) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).atualizarDispensaEmLote(
            casaId: casaId,
            itens: itens,
            userId: user.uid,
          ),
    );
  }

  /// Quick quantity adjustment (ON-mode items only) — used by the pantry
  /// card's +/- stepper. Not wrapped in `AsyncLoading` first (unlike the
  /// mutations above): this fires on every stepper tap and flashing a
  /// loading state on a widget this small/frequent would be more noise than
  /// signal; the guarded result still lands in `state` for error surfacing.
  Future<void> atualizarQuantidade({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).atualizarQuantidade(
            casaId: casaId,
            itemId: itemId,
            quantidade: quantidade,
            estoqueMinimo: estoqueMinimo,
            userId: user.uid,
          ),
    );
  }

  /// Mark/unmark an ON-mode item as being in the cart this trip (Mercado's
  /// equivalent of `atualizarStatus` for OFF-mode items — ON-mode never
  /// cycles `status` manually, see `PantryItem.estaNoCarrinho`).
  Future<void> marcarNoCarrinho({
    required String casaId,
    required String itemId,
    required bool noCarrinho,
  }) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = await AsyncValue.guard(
      () => ref.read(dispensaRepositoryProvider).marcarNoCarrinho(
            casaId: casaId,
            itemId: itemId,
            noCarrinho: noCarrinho,
            userId: user.uid,
          ),
    );
  }
}
