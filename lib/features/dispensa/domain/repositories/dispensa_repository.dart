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
    required ItemStatus statusAnterior,
    required ItemStatus novoStatus,
    required String userId,
  });

  Future<void> deletarItem({
    required String casaId,
    required String itemId,
  });

  /// Cart-close ("fechar carrinho"). For OFF-mode items sets status -> tem
  /// (as before). For ON-mode (quantity-controlled) items it does NOT flip the
  /// status directly: it bumps `quantidade` (v1 = estoqueMinimo + 1) and clears
  /// `noCarrinho`, so the derived status re-computes to tem. Pass the actual
  /// items currently in the cart so each can be handled by its mode.
  Future<void> atualizarDispensaEmLote({
    required String casaId,
    required List<PantryItem> itens,
    required String userId,
  });

  // ---- optional quantity + minimum-stock control -------------------------

  /// Toggle the quantity/minimum-stock control ON for an item. The initial
  /// `quantidade`/`estoqueMinimo` come from the user (mobile prompts, pre-filled
  /// to preserve the item's current status). The derived status is written
  /// alongside so the stored `status` stays consistent with the Firestore rule.
  Future<void> ativarControleEstoque({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
    required String userId,
  });

  /// Toggle the control OFF: freeze [statusCongelado] (the last derived status)
  /// as a plain manual status. `quantidade`/`estoqueMinimo` are retained on the
  /// doc (not deleted) so re-enabling keeps the prior numbers.
  Future<void> desativarControleEstoque({
    required String casaId,
    required String itemId,
    required ItemStatus statusCongelado,
    required String userId,
  });

  /// Update quantity (and/or minimum) of an ON-mode item; the derived status is
  /// recomputed and written. Does not touch `controlaEstoque`.
  Future<void> atualizarQuantidade({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
    required String userId,
  });

  /// Mark/unmark an ON-mode item as being in the cart this trip. Uses the
  /// orthogonal `noCarrinho` flag; never touches the derived status.
  Future<void> marcarNoCarrinho({
    required String casaId,
    required String itemId,
    required bool noCarrinho,
    required String userId,
  });
}
