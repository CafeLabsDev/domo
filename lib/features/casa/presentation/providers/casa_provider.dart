import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/casa_repository_impl.dart';
import '../../domain/models/casa_model.dart';
import '../../domain/models/membro_model.dart';
import '../../domain/repositories/casa_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

part 'casa_provider.g.dart';

@riverpod
CasaRepository casaRepository(CasaRepositoryRef ref) {
  return CasaRepositoryImpl();
}

@riverpod
Stream<CasaModel?> casaDoUsuario(CasaDoUsuarioRef ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) return Stream.value(null);
  return ref.watch(casaRepositoryProvider).watchCasaDoUsuario(user.uid);
}

@riverpod
Stream<List<MembroModel>> membros(MembrosRef ref, String casaId) {
  return ref.watch(casaRepositoryProvider).watchMembros(casaId);
}
