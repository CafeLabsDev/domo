import '../models/pantry_item.dart';

abstract class DispensaRepository {
  Stream<List<PantryItem>> watchItens(String casaId);

  Future<void> adicionarItem({
    required String casaId,
    required String nome,
    required String categoria,
    required String userId,
  });

  Future<void> atualizarItem({
    required String casaId,
    required String itemId,
    required String nome,
    required String categoria,
  });

  Future<void> atualizarStatus({
    required String casaId,
    required String itemId,
    required ItemStatus novoStatus,
    required String userId,
  });

  Future<void> deletarItem({
    required String casaId,
    required String itemId,
  });

  Future<void> atualizarDispensaEmLote({
    required String casaId,
    required List<String> itemIds,
    required String userId,
  });
}
