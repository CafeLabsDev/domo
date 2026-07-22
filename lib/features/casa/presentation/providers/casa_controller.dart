import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import 'casa_provider.dart';

part 'casa_controller.g.dart';

@riverpod
class CasaController extends _$CasaController {
  @override
  FutureOr<void> build() {}

  Future<void> criarCasa(String nome) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).criarCasa(
            nome: nome,
            userId: user.uid,
            nomeUsuario: user.displayName ?? user.email ?? 'Usuário',
            fotoUrl: user.photoURL,
          ),
    );
  }

  Future<void> entrarNaCasa(String codigo) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).entrarNaCasa(
            codigo: codigo,
            userId: user.uid,
            nomeUsuario: user.displayName ?? user.email ?? 'Usuário',
            fotoUrl: user.photoURL,
          ),
    );
  }

  Future<void> aprovarMembro(String casaId, String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).aprovarMembro(
            casaId: casaId,
            userId: userId,
          ),
    );
  }

  Future<void> recusarMembro(String casaId, String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).recusarMembro(
            casaId: casaId,
            userId: userId,
          ),
    );
  }

  Future<void> atualizarCargo(String casaId, String userId, String cargo) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).atualizarCargo(
            casaId: casaId,
            userId: userId,
            cargo: cargo,
          ),
    );
  }

  Future<void> removerMembro(String casaId, String userId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).removerMembroAtivo(
            casaId: casaId,
            userId: userId,
          ),
    );
  }

  Future<void> sairDaCasa(String casaId) async {
    final user = ref.read(authStateProvider).valueOrNull;
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).removerMembroAtivo(
            casaId: casaId,
            userId: user.uid,
          ),
    );
  }

  Future<void> deletarCasa(String casaId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).deletarCasa(casaId: casaId),
    );
  }

  /// Feature 3 — save the per-house category display order (any active
  /// member may call this, enforced in firestore.rules).
  Future<void> atualizarOrdemCategorias(
    String casaId,
    List<String> ordem,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(casaRepositoryProvider).atualizarOrdemCategorias(
            casaId: casaId,
            ordem: ordem,
          ),
    );
  }
}
