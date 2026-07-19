import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/analytics/analytics_service.dart';
import '../../domain/models/casa_model.dart';
import '../../domain/models/membro_model.dart';
import '../../domain/repositories/casa_repository.dart';

class CasaRepositoryImpl implements CasaRepository {
  CasaRepositoryImpl({AnalyticsService? analytics, FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance,
        _analytics = analytics ?? AnalyticsService();

  final FirebaseFirestore _db;
  final AnalyticsService _analytics;

  CollectionReference<Map<String, dynamic>> get _casas =>
      _db.collection('casas');

  CollectionReference<Map<String, dynamic>> get _codigos =>
      _db.collection('codigos');

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

    // The codigos/{CODE} lookup doc MUST be created as a second, sequential
    // write after the casa doc above has committed — not batched/transacted
    // together with it. The `codigos` create rule authorizes via
    // get(casas/$(casaId)).criadoPor, which only ever sees state that is
    // already committed to the database; a batch or transaction evaluates
    // rules against the pre-request state, so it would never see this casa
    // doc and the codigos write would be denied. See firestore.rules
    // (match /codigos/{codigo}) for the authoritative note.
    try {
      await _codigos.doc(codigo).set({
        'casaId': docRef.id,
        'nome': nome,
      });
    } catch (e) {
      // Don't leave an orphaned house that nobody can join by code.
      await docRef.delete();
      rethrow;
    }

    // Both docs committed: the house genuinely exists and is joinable.
    unawaited(_analytics.logCasaCriada());

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
    final codigoSnap = await _codigos.doc(codigo.toUpperCase()).get();

    if (!codigoSnap.exists) {
      throw Exception('Código inválido. Verifique e tente novamente.');
    }

    final casaId = codigoSnap.data()!['casaId'] as String;
    final docRef = _casas.doc(casaId);
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

    // Member record committed: the user has genuinely joined (pending
    // approval), not just typed a code that happened to be well-formed.
    unawaited(_analytics.logCasaEntrou());
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
    final docRef = _casas.doc(casaId);

    // Read the casa's codigo first: we need it to address the codigos/{CODE}
    // lookup doc, and the codigos delete rule's get(casas/$(casaId)) check
    // needs the casa doc to still exist. A batch is safe HERE (unlike in
    // criarCasa) because batched writes evaluate rules against the
    // pre-request state, and pre-request the casa doc is still fully intact.
    final snap = await docRef.get();
    final codigo = snap.data()?['codigo'] as String?;

    final batch = _db.batch();
    if (codigo != null) {
      batch.delete(_codigos.doc(codigo));
    }
    batch.delete(docRef);
    await batch.commit();
  }
}
