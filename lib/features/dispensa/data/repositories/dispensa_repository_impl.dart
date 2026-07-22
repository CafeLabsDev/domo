import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../domain/models/pantry_item.dart';
import '../../domain/repositories/dispensa_repository.dart';

class DispensaRepositoryImpl implements DispensaRepository {
  DispensaRepositoryImpl({AnalyticsService? analytics})
      : _analytics = analytics ?? AnalyticsService();

  final _firestore = FirebaseFirestore.instance;
  final AnalyticsService _analytics;

  CollectionReference<Map<String, dynamic>> _itensRef(String casaId) =>
      _firestore.collection('casas').doc(casaId).collection('itens');

  @override
  Stream<List<PantryItem>> watchItens(String casaId) {
    return _itensRef(casaId).orderBy('nome').snapshots().map(
          (snap) => snap.docs
              .map(
                (doc) => PantryItem.fromJson({
                  ...doc.data(),
                  'id': doc.id,
                  'casaId': casaId,
                }),
              )
              .toList(),
        );
  }

  @override
  Future<void> adicionarItem({
    required String casaId,
    required String nome,
    required String categoria,
    required String userId,
  }) async {
    await _itensRef(casaId).add({
      'nome': nome,
      'categoria': categoria,
      'status': ItemStatus.naoTem.firestoreValue,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });
  }

  @override
  Future<void> atualizarItem({
    required String casaId,
    required String itemId,
    required String nome,
    required String categoria,
  }) async {
    await _itensRef(casaId).doc(itemId).update({
      'nome': nome,
      'categoria': categoria,
    });
  }

  @override
  Future<void> atualizarStatus({
    required String casaId,
    required String itemId,
    required ItemStatus statusAnterior,
    required ItemStatus novoStatus,
    required String userId,
  }) async {
    await _itensRef(casaId).doc(itemId).update({
      'status': novoStatus.firestoreValue,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });

    unawaited(
      _analytics.logItemStatusAlterado(
        statusAnterior: statusAnterior.firestoreValue,
        statusNovo: novoStatus.firestoreValue,
      ),
    );
  }

  @override
  Future<void> deletarItem({
    required String casaId,
    required String itemId,
  }) async {
    await _itensRef(casaId).doc(itemId).delete();
  }

  @override
  Future<void> atualizarDispensaEmLote({
    required String casaId,
    required List<PantryItem> itens,
    required String userId,
  }) async {
    final batch = _firestore.batch();
    for (final item in itens) {
      final ref = _itensRef(casaId).doc(item.id);
      if (item.controlaEstoque) {
        // Quantity item: do NOT flip status directly. Bump quantidade so the
        // derived status re-computes to tem, and clear the cart flag.
        final estoqueMinimo = item.estoqueMinimo ?? 0;
        final novaQuantidade = estoqueMinimo + 1;
        batch.update(ref, {
          'quantidade': novaQuantidade,
          'status': PantryItem.statusPorQuantidade(novaQuantidade, estoqueMinimo)
              .firestoreValue,
          'noCarrinho': false,
          'atualizadoEm': FieldValue.serverTimestamp(),
          'atualizadoPor': userId,
        });
      } else {
        batch.update(ref, {
          'status': ItemStatus.tem.firestoreValue,
          'atualizadoEm': FieldValue.serverTimestamp(),
          'atualizadoPor': userId,
        });
      }
    }
    await batch.commit();

    unawaited(
      _analytics.logCarrinhoFechado(quantidadeItens: itens.length),
    );
  }

  @override
  Future<void> ativarControleEstoque({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
    required String userId,
  }) async {
    final status = PantryItem.statusPorQuantidade(quantidade, estoqueMinimo);
    await _itensRef(casaId).doc(itemId).update({
      'controlaEstoque': true,
      'quantidade': quantidade,
      'estoqueMinimo': estoqueMinimo,
      'noCarrinho': false,
      'status': status.firestoreValue,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });
  }

  @override
  Future<void> desativarControleEstoque({
    required String casaId,
    required String itemId,
    required ItemStatus statusCongelado,
    required String userId,
  }) async {
    // Retain quantidade/estoqueMinimo on the doc (don't delete); just freeze the
    // derived status as a plain manual status and clear the cart flag.
    await _itensRef(casaId).doc(itemId).update({
      'controlaEstoque': false,
      'noCarrinho': false,
      'status': statusCongelado.firestoreValue,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });
  }

  @override
  Future<void> atualizarQuantidade({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
    required String userId,
  }) async {
    final status = PantryItem.statusPorQuantidade(quantidade, estoqueMinimo);
    await _itensRef(casaId).doc(itemId).update({
      'quantidade': quantidade,
      'estoqueMinimo': estoqueMinimo,
      'status': status.firestoreValue,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });

    // Deliberate user edit (stepper or edit-item form) — NOT the cart-close
    // default bump, which lives in atualizarDispensaEmLote and must never
    // fire this event (see logItemQuantidadeAtualizada docs).
    unawaited(
      _analytics.logItemQuantidadeAtualizada(
        statusResultante: status.firestoreValue,
      ),
    );
  }

  @override
  Future<void> marcarNoCarrinho({
    required String casaId,
    required String itemId,
    required bool noCarrinho,
    required String userId,
  }) async {
    await _itensRef(casaId).doc(itemId).update({
      'noCarrinho': noCarrinho,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });
  }
}
