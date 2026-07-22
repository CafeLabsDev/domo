import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:domo/features/auth/presentation/providers/auth_provider.dart';
import 'package:domo/features/dispensa/domain/models/pantry_item.dart';
import 'package:domo/features/dispensa/domain/repositories/dispensa_repository.dart';
import 'package:domo/features/dispensa/presentation/providers/dispensa_provider.dart';
import 'package:domo/features/dispensa/presentation/widgets/add_edit_item_sheet.dart';

class _MockUser extends Mock implements User {}

/// Fake that records every call this sheet can make instead of touching
/// Firestore — keeps this a pure widget-level test of "does flipping the
/// toggle / tapping Salvar call the repository with the right params".
class _FakeDispensaRepository implements DispensaRepository {
  final ativarCalls = <({
    String itemId,
    int quantidade,
    int estoqueMinimo,
  })>[];
  final desativarCalls = <({String itemId, ItemStatus statusCongelado})>[];
  final atualizarQuantidadeCalls = <({
    String itemId,
    int quantidade,
    int estoqueMinimo,
  })>[];
  final atualizarItemCalls = <({String itemId, String nome, String categoria})>[];

  @override
  Future<void> adicionarItem({
    required String casaId,
    required String nome,
    required String categoria,
    required String userId,
  }) async {}

  @override
  Future<void> atualizarItem({
    required String casaId,
    required String itemId,
    required String nome,
    required String categoria,
  }) async {
    atualizarItemCalls.add((itemId: itemId, nome: nome, categoria: categoria));
  }

  @override
  Future<void> atualizarStatus({
    required String casaId,
    required String itemId,
    required ItemStatus statusAnterior,
    required ItemStatus novoStatus,
    required String userId,
  }) async {}

  @override
  Future<void> deletarItem({
    required String casaId,
    required String itemId,
  }) async {}

  @override
  Future<void> atualizarDispensaEmLote({
    required String casaId,
    required List<PantryItem> itens,
    required String userId,
  }) async {}

  @override
  Future<void> ativarControleEstoque({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
    required String userId,
  }) async {
    ativarCalls.add((
      itemId: itemId,
      quantidade: quantidade,
      estoqueMinimo: estoqueMinimo,
    ));
  }

  @override
  Future<void> desativarControleEstoque({
    required String casaId,
    required String itemId,
    required ItemStatus statusCongelado,
    required String userId,
  }) async {
    desativarCalls.add((itemId: itemId, statusCongelado: statusCongelado));
  }

  @override
  Future<void> atualizarQuantidade({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
    required String userId,
  }) async {
    atualizarQuantidadeCalls.add((
      itemId: itemId,
      quantidade: quantidade,
      estoqueMinimo: estoqueMinimo,
    ));
  }

  @override
  Future<void> marcarNoCarrinho({
    required String casaId,
    required String itemId,
    required bool noCarrinho,
    required String userId,
  }) async {}

  @override
  Stream<List<PantryItem>> watchItens(String casaId) => const Stream.empty();
}

PantryItem _item({
  required ItemStatus status,
  bool controlaEstoque = false,
  int? quantidade,
  int? estoqueMinimo,
}) =>
    PantryItem(
      id: 'item1',
      casaId: 'casa1',
      nome: 'Leite integral',
      categoria: 'Laticínios',
      status: status,
      atualizadoEm: DateTime(2026, 1, 1),
      atualizadoPor: 'u1',
      controlaEstoque: controlaEstoque,
      quantidade: quantidade,
      estoqueMinimo: estoqueMinimo,
    );

Future<_FakeDispensaRepository> _pumpSheet(
  WidgetTester tester, {
  PantryItem? item,
}) async {
  final repo = _FakeDispensaRepository();
  final user = _MockUser();
  when(() => user.uid).thenReturn('u1');

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dispensaRepositoryProvider.overrideWith((ref) => repo),
        authStateProvider.overrideWith((ref) => Stream.value(user)),
      ],
      child: MaterialApp(
        home: Scaffold(
          // `authStateProvider` is only ever `ref.read` inside `_save()`
          // (never `ref.watch` by the sheet itself), so nothing forces the
          // stream override to actually start emitting before the widget is
          // interacted with. Force it to resolve during the initial pump
          // here (test-only) so `_save()` doesn't read a still-`AsyncLoading`
          // auth state when it later calls `ref.read(authStateProvider)`.
          body: Consumer(
            builder: (context, ref, _) {
              ref.watch(authStateProvider);
              return AddEditItemSheet(casaId: 'casa1', item: item);
            },
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
  return repo;
}

void main() {
  testWidgets('item novo não mostra o controle de quantidade', (tester) async {
    await _pumpSheet(tester);

    expect(find.text('Controlar quantidade'), findsNothing);
  });

  testWidgets(
      'ligar o switch em um item "tem" pré-preenche quantidade=2/estoqueMinimo=1',
      (tester) async {
    await _pumpSheet(tester, item: _item(status: ItemStatus.tem));

    await tester.tap(find.text('Controlar quantidade'));
    await tester.pump();

    expect(find.widgetWithText(TextField, 'Quantidade'), findsOneWidget);
    final quantidadeField =
        tester.widget<TextField>(find.widgetWithText(TextField, 'Quantidade'));
    final minField = tester
        .widget<TextField>(find.widgetWithText(TextField, 'Estoque mínimo'));
    expect(quantidadeField.controller!.text, '2');
    expect(minField.controller!.text, '1');
  });

  testWidgets(
      'ligar o switch em um item "falta" pré-preenche quantidade=0/estoqueMinimo=1',
      (tester) async {
    await _pumpSheet(tester, item: _item(status: ItemStatus.naoTem));

    await tester.tap(find.text('Controlar quantidade'));
    await tester.pump();

    final quantidadeField =
        tester.widget<TextField>(find.widgetWithText(TextField, 'Quantidade'));
    final minField = tester
        .widget<TextField>(find.widgetWithText(TextField, 'Estoque mínimo'));
    expect(quantidadeField.controller!.text, '0');
    expect(minField.controller!.text, '1');
  });

  testWidgets(
      'salvar com o switch ligado chama ativarControleEstoque com os valores preenchidos',
      (tester) async {
    final repo = await _pumpSheet(tester, item: _item(status: ItemStatus.tem));

    await tester.tap(find.text('Controlar quantidade'));
    await tester.pump();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repo.ativarCalls, hasLength(1));
    expect(repo.ativarCalls.single.itemId, 'item1');
    expect(repo.ativarCalls.single.quantidade, 2);
    expect(repo.ativarCalls.single.estoqueMinimo, 1);
  });

  testWidgets(
      'desligar o switch de um item já ON chama desativarControleEstoque '
      'congelando o status atual', (tester) async {
    final repo = await _pumpSheet(
      tester,
      item: _item(
        status: ItemStatus.naoTem,
        controlaEstoque: true,
        quantidade: 0,
        estoqueMinimo: 1,
      ),
    );

    // O switch já começa ligado — desligar.
    await tester.tap(find.text('Controlar quantidade'));
    await tester.pump();

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repo.desativarCalls, hasLength(1));
    expect(repo.desativarCalls.single.itemId, 'item1');
    expect(repo.desativarCalls.single.statusCongelado, ItemStatus.naoTem);
    expect(repo.ativarCalls, isEmpty);
  });

  testWidgets(
      'salvar com quantidade vazia mostra erro inline e não chama o repositório',
      (tester) async {
    final repo = await _pumpSheet(tester, item: _item(status: ItemStatus.tem));

    await tester.tap(find.text('Controlar quantidade'));
    await tester.pump();

    // Limpa o campo de quantidade pré-preenchido.
    await tester.enterText(
      find.widgetWithText(TextField, 'Quantidade'),
      '',
    );
    await tester.tap(find.text('Salvar'));
    await tester.pump();

    expect(
      find.text('Informe quantidade e estoque mínimo (0 ou mais).'),
      findsOneWidget,
    );
    expect(repo.ativarCalls, isEmpty);
  });

  testWidgets('editar apenas nome/categoria (switch continua desligado) '
      'não chama ativarControleEstoque nem desativarControleEstoque',
      (tester) async {
    final repo = await _pumpSheet(tester, item: _item(status: ItemStatus.tem));

    await tester.tap(find.text('Salvar'));
    await tester.pumpAndSettle();

    expect(repo.atualizarItemCalls, hasLength(1));
    expect(repo.ativarCalls, isEmpty);
    expect(repo.desativarCalls, isEmpty);
  });
}
