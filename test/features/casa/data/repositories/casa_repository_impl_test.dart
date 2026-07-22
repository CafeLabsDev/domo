import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:domo/core/analytics/analytics_service.dart';
import 'package:domo/features/casa/data/repositories/casa_repository_impl.dart';

/// Fakes [AnalyticsService] so `criarCasa`/`entrarNaCasa` don't fall through
/// to the real `analytics ?? AnalyticsService()` default, which would touch
/// `FirebaseAnalytics.instance` and blow up without a real Firebase app.
class _MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late FakeFirebaseFirestore firestore;
  late _MockAnalyticsService analytics;
  late CasaRepositoryImpl repo;

  setUp(() {
    firestore = FakeFirebaseFirestore();
    analytics = _MockAnalyticsService();
    when(() => analytics.logCasaCriada()).thenAnswer((_) async {});
    when(() => analytics.logCasaEntrou()).thenAnswer((_) async {});
    when(() => analytics.logCasaOrdemCategoriasAlterada(
          quantidadeCategorias: any(named: 'quantidadeCategorias'),
        )).thenAnswer((_) async {});
    repo = CasaRepositoryImpl(firestore: firestore, analytics: analytics);
  });

  group('criarCasa', () {
    test('grava o doc da casa E o lookup codigos/{CODE}', () async {
      final casa = await repo.criarCasa(
        nome: 'Casa da Ana',
        userId: 'u1',
        nomeUsuario: 'Ana',
      );

      final casaSnap =
          await firestore.collection('casas').doc(casa.id).get();
      expect(casaSnap.exists, isTrue);
      expect(casaSnap.data()!['nome'], 'Casa da Ana');
      expect(casaSnap.data()!['criadoPor'], 'u1');
      expect(casaSnap.data()!['codigo'], casa.codigo);
      expect(casaSnap.data()!['membrosAtivos'], ['u1']);
      final membros = casaSnap.data()!['membros'] as Map<String, dynamic>;
      expect(membros['u1']['cargo'], 'Administrador');
      expect(membros['u1']['status'], 'ativo');

      final codigoSnap =
          await firestore.collection('codigos').doc(casa.codigo).get();
      expect(codigoSnap.exists, isTrue);
      expect(codigoSnap.data()!['casaId'], casa.id);
      expect(codigoSnap.data()!['nome'], 'Casa da Ana');
    });

    test('gera um código de 6 caracteres em maiúsculas', () async {
      final casa = await repo.criarCasa(
        nome: 'Casa X',
        userId: 'u1',
        nomeUsuario: 'Ana',
      );

      expect(casa.codigo.length, 6);
      expect(casa.codigo, casa.codigo.toUpperCase());
    });
  });

  group('entrarNaCasa', () {
    test('código válido lê o lookup e adiciona membro pendente', () async {
      final casa = await repo.criarCasa(
        nome: 'Casa da Bia',
        userId: 'u1',
        nomeUsuario: 'Bia',
      );

      await repo.entrarNaCasa(
        codigo: casa.codigo,
        userId: 'u2',
        nomeUsuario: 'Caio',
      );

      final casaSnap =
          await firestore.collection('casas').doc(casa.id).get();
      final membros = casaSnap.data()!['membros'] as Map<String, dynamic>;
      expect(membros['u2']['nome'], 'Caio');
      expect(membros['u2']['cargo'], 'Membro');
      expect(membros['u2']['status'], 'pendente');

      // membrosAtivos não deve incluir quem ainda está pendente de aprovação.
      final membrosAtivos = casaSnap.data()!['membrosAtivos'] as List;
      expect(membrosAtivos.contains('u2'), isFalse);
    });

    test('aceita o código em minúsculas (normaliza antes de buscar)',
        () async {
      final casa = await repo.criarCasa(
        nome: 'Casa do Davi',
        userId: 'u1',
        nomeUsuario: 'Davi',
      );

      await repo.entrarNaCasa(
        codigo: casa.codigo.toLowerCase(),
        userId: 'u2',
        nomeUsuario: 'Eva',
      );

      final casaSnap =
          await firestore.collection('casas').doc(casa.id).get();
      final membros = casaSnap.data()!['membros'] as Map<String, dynamic>;
      expect(membros['u2'], isNotNull);
    });

    test('código inexistente falha de forma limpa (sem tocar em nenhuma casa)',
        () async {
      expect(
        () => repo.entrarNaCasa(
          codigo: 'ZZZZZZ',
          userId: 'u2',
          nomeUsuario: 'Caio',
        ),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('deletarCasa', () {
    test('remove o doc da casa E o lookup codigos/{CODE}', () async {
      final casa = await repo.criarCasa(
        nome: 'Casa a apagar',
        userId: 'u1',
        nomeUsuario: 'Fê',
      );

      await repo.deletarCasa(casaId: casa.id);

      final casaSnap =
          await firestore.collection('casas').doc(casa.id).get();
      final codigoSnap =
          await firestore.collection('codigos').doc(casa.codigo).get();
      expect(casaSnap.exists, isFalse);
      expect(codigoSnap.exists, isFalse);
    });
  });

  group('atualizarOrdemCategorias', () {
    test('grava ordemCategorias no doc da casa', () async {
      final casa = await repo.criarCasa(
        nome: 'Casa da Ordem',
        userId: 'u1',
        nomeUsuario: 'Ana',
      );

      final ordem = ['Bebidas', 'Outros', 'Laticínios'];
      await repo.atualizarOrdemCategorias(casaId: casa.id, ordem: ordem);

      final casaSnap =
          await firestore.collection('casas').doc(casa.id).get();
      expect(casaSnap.data()!['ordemCategorias'], ordem);
    });

    test('não toca em outros campos da casa (nome, membros, criadoPor)',
        () async {
      final casa = await repo.criarCasa(
        nome: 'Casa Intacta',
        userId: 'u1',
        nomeUsuario: 'Ana',
      );

      await repo.atualizarOrdemCategorias(
        casaId: casa.id,
        ordem: ['Bebidas'],
      );

      final casaSnap =
          await firestore.collection('casas').doc(casa.id).get();
      expect(casaSnap.data()!['nome'], 'Casa Intacta');
      expect(casaSnap.data()!['criadoPor'], 'u1');
      expect(
        (casaSnap.data()!['membros'] as Map<String, dynamic>).containsKey('u1'),
        isTrue,
      );
    });
  });
}
