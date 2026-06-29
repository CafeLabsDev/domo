import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/pantry_item.dart';
import '../../domain/repositories/dispensa_repository.dart';

class DispensaRepositoryImpl implements DispensaRepository {
  final _firestore = FirebaseFirestore.instance;

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
    required ItemStatus novoStatus,
    required String userId,
  }) async {
    await _itensRef(casaId).doc(itemId).update({
      'status': novoStatus.firestoreValue,
      'atualizadoEm': FieldValue.serverTimestamp(),
      'atualizadoPor': userId,
    });
  }

  @override
  Future<void> deletarItem({
    required String casaId,
    required String itemId,
  }) async {
    await _itensRef(casaId).doc(itemId).delete();
  }
}
