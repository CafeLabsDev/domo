import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/dispensa_repository_impl.dart';
import '../../domain/models/pantry_item.dart';
import '../../domain/repositories/dispensa_repository.dart';

part 'dispensa_provider.g.dart';

@riverpod
DispensaRepository dispensaRepository(DispensaRepositoryRef ref) {
  return DispensaRepositoryImpl();
}

@riverpod
Stream<List<PantryItem>> itens(ItensRef ref, String casaId) {
  return ref.watch(dispensaRepositoryProvider).watchItens(casaId);
}
