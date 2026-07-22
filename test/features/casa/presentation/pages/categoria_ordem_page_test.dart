import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/casa/domain/models/casa_model.dart';
import 'package:domo/features/casa/domain/models/membro_model.dart';
import 'package:domo/features/casa/domain/repositories/casa_repository.dart';
import 'package:domo/features/casa/presentation/pages/categoria_ordem_page.dart';
import 'package:domo/l10n/app_localizations.dart';
import 'package:domo/features/casa/presentation/providers/casa_provider.dart';
import 'package:domo/features/dispensa/domain/constants.dart';

/// Fake that records every `atualizarOrdemCategorias` call instead of
/// touching Firestore — the other `CasaRepository` methods aren't exercised
/// by this page, so they're minimal stubs.
class _FakeCasaRepository implements CasaRepository {
  final ordemCalls = <({String casaId, List<String> ordem})>[];

  @override
  Future<void> atualizarOrdemCategorias({
    required String casaId,
    required List<String> ordem,
  }) async {
    ordemCalls.add((casaId: casaId, ordem: ordem));
  }

  @override
  Future<void> aprovarMembro({required String casaId, required String userId}) async {}

  @override
  Future<CasaModel> criarCasa({
    required String nome,
    required String userId,
    required String nomeUsuario,
    String? fotoUrl,
  }) async =>
      throw UnimplementedError();

  @override
  Future<void> deletarCasa({required String casaId}) async {}

  @override
  Future<void> entrarNaCasa({
    required String codigo,
    required String userId,
    required String nomeUsuario,
    String? fotoUrl,
  }) async {}

  @override
  Future<void> recusarMembro({required String casaId, required String userId}) async {}

  @override
  Future<void> removerMembroAtivo({
    required String casaId,
    required String userId,
  }) async {}

  @override
  Future<void> atualizarCargo({
    required String casaId,
    required String userId,
    required String cargo,
  }) async {}

  @override
  Stream<CasaModel?> watchCasaDoUsuario(String userId) => const Stream.empty();

  @override
  Stream<List<MembroModel>> watchMembros(String casaId) => const Stream.empty();
}

final _casaSemOrdem = CasaModel(
  id: 'casa1',
  nome: 'Casa da Família',
  codigo: 'ABC123',
  criadoPor: 'u1',
  criadoEm: DateTime(2026, 1, 1),
);

Future<_FakeCasaRepository> _pumpPage(
  WidgetTester tester, {
  CasaModel? casa,
}) async {
  // The list is built lazily (ReorderableListView.builder): the default test
  // surface is too short to fit all 8 category rows + the description text +
  // the bottom Salvar button at once, so the last couple of rows never get
  // built/found by finders. Widen the surface instead of scrolling per test.
  tester.view.physicalSize = const Size(400, 1400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final repo = _FakeCasaRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        casaDoUsuarioProvider.overrideWith(
          (ref) => Stream.value(casa ?? _casaSemOrdem),
        ),
        casaRepositoryProvider.overrideWith((ref) => repo),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CategoriaOrdemPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return repo;
}

void main() {
  testWidgets('mostra as 8 categorias fixas na ordem padrão quando a casa '
      'não tem ordem salva', (tester) async {
    await _pumpPage(tester);

    for (final categoria in kDispensaCategorias) {
      expect(find.text(categoria), findsOneWidget);
    }
  });

  testWidgets('mostra a ordem customizada salva da casa quando presente',
      (tester) async {
    final ordem = [
      'Bebidas',
      'Outros',
      ...kDispensaCategorias.where((c) => c != 'Bebidas' && c != 'Outros'),
    ];
    await _pumpPage(
      tester,
      casa: _casaSemOrdem.copyWith(ordemCategorias: ordem),
    );

    final tiles = tester.widgetList<ListTile>(find.byType(ListTile)).toList();
    expect((tiles[0].title as Text).data, 'Bebidas');
    expect((tiles[1].title as Text).data, 'Outros');
  });

  testWidgets('o botão Salvar começa desabilitado (nada foi reordenado ainda)',
      (tester) async {
    await _pumpPage(tester);

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNull);
  });

  testWidgets(
      'reordenar (via onReorderItem) habilita o Salvar e persiste a nova '
      'ordem através de CasaRepository.atualizarOrdemCategorias',
      (tester) async {
    final repo = await _pumpPage(tester);

    // Simula o drag chamando o callback do ReorderableListView diretamente
    // (técnica padrão para testar ReorderableListView sem simular o gesto de
    // arrastar pixel a pixel) — move o primeiro item (índice 0) para o fim.
    final reorderable = tester.widget<ReorderableListView>(
      find.byType(ReorderableListView),
    );
    reorderable.onReorderItem!(0, kDispensaCategorias.length - 1);
    await tester.pump();

    final button = tester.widget<FilledButton>(find.byType(FilledButton));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.text('Salvar ordem'));
    await tester.pumpAndSettle();

    expect(repo.ordemCalls, hasLength(1));
    expect(repo.ordemCalls.single.casaId, 'casa1');
    final salvo = repo.ordemCalls.single.ordem;
    expect(salvo.length, kDispensaCategorias.length);
    expect(salvo.first, isNot(kDispensaCategorias.first));
  });
}
