import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/models/casa_model.dart';
import '../../domain/models/membro_model.dart';
import '../../domain/repositories/casa_repository.dart';

class CasaRepositoryImpl implements CasaRepository {
  CasaRepositoryImpl() : _db = FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _casas =>
      _db.collection('casas');

  String _gerarCodigo() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rand = Random.secure();
    return List.generate(6, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  @override
  Stream<CasaModel?> watchCasaDoUsuario(String userId) {
    return _casas
        .where('membrosAtivos', arrayContains: userId)
        .limit(1)
        .snapshots()
        .map((snap) {
      if (snap.docs.isEmpty) return null;
      final doc = snap.docs.first;
      return CasaModel.fromJson({...doc.data(), 'id': doc.id});
    });
  }

  @override
  Future<CasaModel> criarCasa({
    required String nome,
    required String userId,
    required String nomeUsuario,
    String? fotoUrl,
  }) async {
    final codigo = _gerarCodigo();
    final now = DateTime.now();

    final docRef = _casas.doc();

    final membro = MembroModel(
      userId: userId,
      nome: nomeUsuario,
      cargo: 'Administrador',
      fotoUrl: fotoUrl,
      status: MembroStatus.ativo,
    );

    await docRef.set({
      'nome': nome,
      'codigo': codigo,
      'criadoPor': userId,
      'criadoEm': Timestamp.fromDate(now),
      'membrosAtivos': [userId],
      'membros': {userId: membro.toJson()},
    });

    return CasaModel(
      id: docRef.id,
      nome: nome,
      codigo: codigo,
      criadoPor: userId,
      criadoEm: now,
    );
  }

  @override
  Future<void> entrarNaCasa({
    required String codigo,
    required String userId,
    required String nomeUsuario,
    String? fotoUrl,
  }) async {
    final snap = await _casas
        .where('codigo', isEqualTo: codigo.toUpperCase())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) {
      throw Exception('Código inválido. Verifique e tente novamente.');
    }

    final docRef = snap.docs.first.reference;
    final membro = MembroModel(
      userId: userId,
      nome: nomeUsuario,
      cargo: 'Membro',
      fotoUrl: fotoUrl,
      status: MembroStatus.pendente,
    );

    await docRef.update({
      'membros.$userId': membro.toJson(),
    });
  }

  @override
  Stream<List<MembroModel>> watchMembros(String casaId) {
    return _casas.doc(casaId).snapshots().map((snap) {
      if (!snap.exists) return [];
      final data = snap.data()!;
      final membrosMap = data['membros'] as Map<String, dynamic>? ?? {};
      return membrosMap.values
          .map((m) => MembroModel.fromJson(m as Map<String, dynamic>))
          .toList();
    });
  }

  @override
  Future<void> aprovarMembro({
    required String casaId,
    required String userId,
  }) async {
    await _casas.doc(casaId).update({
      'membros.$userId.status': 'ativo',
      'membrosAtivos': FieldValue.arrayUnion([userId]),
    });
  }

  @override
  Future<void> recusarMembro({
    required String casaId,
    required String userId,
  }) async {
    await _casas.doc(casaId).update({
      'membros.$userId': FieldValue.delete(),
    });
  }

  @override
  Future<void> atualizarCargo({
    required String casaId,
    required String userId,
    required String cargo,
  }) async {
    await _casas.doc(casaId).update({
      'membros.$userId.cargo': cargo,
    });
  }

  @override
  Future<void> removerMembroAtivo({
    required String casaId,
    required String userId,
  }) async {
    await _casas.doc(casaId).update({
      'membros.$userId': FieldValue.delete(),
      'membrosAtivos': FieldValue.arrayRemove([userId]),
    });
  }

  @override
  Future<void> deletarCasa({required String casaId}) async {
    await _casas.doc(casaId).delete();
  }
}
