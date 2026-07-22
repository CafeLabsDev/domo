import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/casa/domain/models/casa_model.dart';
import 'package:domo/features/casa/presentation/providers/casa_provider.dart';
import 'package:domo/features/dispensa/domain/models/pantry_item.dart';
import 'package:domo/features/dispensa/presentation/providers/dispensa_controller.dart';
import 'package:domo/features/dispensa/presentation/providers/dispensa_provider.dart';
import 'package:domo/features/mercado/presentation/pages/mercado_page.dart';
import 'package:domo/l10n/app_localizations.dart';

/// Records every mutating call instead of touching
/// `dispensaRepositoryProvider`/`authStateProvider` — same pattern as
/// `pantry_item_card_test.dart`. The recorded lists are injected (not owned
/// by the notifier instance itself): `MercadoPage` drives `itensProvider`'s
/// stream through `casaAsync`/`itensAsync`, which can rebuild
/// `_MercadoContent` more than once per `pumpAndSettle` — an auto-dispose
/// `overrideWith` factory that kept returning the SAME already-attached
/// notifier instance across those rebuilds crashes Riverpod internally
/// (`_element` already initialized). Returning a fresh instance per rebuild
/// but writing into shared lists sidesteps that while still letting the test
/// assert on every call made across the widget's lifetime.
class _RecordingDispensaController extends DispensaController {
  _RecordingDispensaController({
    required this.statusCalls,
    required this.marcarNoCarrinhoCalls,
    required this.loteCalls,
  });

  final List<({String itemId, ItemStatus statusAnterior, ItemStatus novoStatus})>
      statusCalls;
  final List<({String itemId, bool noCarrinho})> marcarNoCarrinhoCalls;
  final List<List<PantryItem>> loteCalls;

  @override
  FutureOr<void> build() {}

  @override
  Future<void> atualizarStatus({
    required String casaId,
    required String itemId,
    required ItemStatus statusAnterior,
    required ItemStatus novoStatus,
  }) async {
    statusCalls.add((
      itemId: itemId,
      statusAnterior: statusAnterior,
      novoStatus: novoStatus,
    ));
  }

  @override
  Future<void> marcarNoCarrinho({
    required String casaId,
    required String itemId,
    required bool noCarrinho,
  }) async {
    marcarNoCarrinhoCalls.add((itemId: itemId, noCarrinho: noCarrinho));
  }

  @override
  Future<void> atualizarDispensaEmLote({
    required String casaId,
    required List<PantryItem> itens,
  }) async {
    loteCalls.add(itens);
  }
}

final _casa = CasaModel(
  id: 'casa1',
  nome: 'Casa da Família',
  codigo: 'ABC123',
  criadoPor: 'u1',
  criadoEm: DateTime(2026, 1, 1),
);

PantryItem _itemOff({
  required String id,
  required ItemStatus status,
  String categoria = 'Laticínios',
}) =>
    PantryItem(
      id: id,
      casaId: _casa.id,
      nome: 'Item $id',
      categoria: categoria,
      status: status,
      atualizadoEm: DateTime(2026, 1, 1),
      atualizadoPor: 'u1',
    );

PantryItem _itemOn({
  required String id,
  required int quantidade,
  required int estoqueMinimo,
  bool noCarrinho = false,
  String categoria = 'Laticínios',
}) =>
    PantryItem(
      id: id,
      casaId: _casa.id,
      nome: 'Item $id',
      categoria: categoria,
      status: PantryItem.statusPorQuantidade(quantidade, estoqueMinimo),
      atualizadoEm: DateTime(2026, 1, 1),
      atualizadoPor: 'u1',
      controlaEstoque: true,
      quantidade: quantidade,
      estoqueMinimo: estoqueMinimo,
      noCarrinho: noCarrinho,
    );

typedef _RecordedCalls = ({
  List<({String itemId, ItemStatus statusAnterior, ItemStatus novoStatus})>
      statusCalls,
  List<({String itemId, bool noCarrinho})> marcarNoCarrinhoCalls,
  List<List<PantryItem>> loteCalls,
});

Future<_RecordedCalls> _pumpMercado(
  WidgetTester tester, {
  required List<PantryItem> itens,
}) async {
  final calls = (
    statusCalls: <({String itemId, ItemStatus statusAnterior, ItemStatus novoStatus})>[],
    marcarNoCarrinhoCalls: <({String itemId, bool noCarrinho})>[],
    loteCalls: <List<PantryItem>>[],
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        casaDoUsuarioProvider.overrideWith((ref) => Stream.value(_casa)),
        itensProvider(_casa.id).overrideWith((ref) => Stream.value(itens)),
        dispensaControllerProvider.overrideWith(
          () => _RecordingDispensaController(
            statusCalls: calls.statusCalls,
            marcarNoCarrinhoCalls: calls.marcarNoCarrinhoCalls,
            loteCalls: calls.loteCalls,
          ),
        ),
      ],
      child: const MaterialApp(
        locale: Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: MercadoPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return calls;
}

void main() {
  testWidgets('item ON em falta (emFalta) aparece na lista mesmo sem estar '
      'marcado no carrinho', (tester) async {
    await _pumpMercado(
      tester,
      itens: [_itemOn(id: 'i1', quantidade: 0, estoqueMinimo: 2)],
    );

    expect(find.text('Item i1'), findsOneWidget);
  });

  testWidgets(
      'item ON com estoque suficiente e fora do carrinho NÃO aparece na lista',
      (tester) async {
    await _pumpMercado(
      tester,
      itens: [_itemOn(id: 'i1', quantidade: 5, estoqueMinimo: 2)],
    );

    expect(find.text('Nada para comprar'), findsOneWidget);
  });

  testWidgets('item OFF "tem" não aparece; item OFF "falta" aparece',
      (tester) async {
    await _pumpMercado(
      tester,
      itens: [
        _itemOff(id: 'i1', status: ItemStatus.tem),
        _itemOff(id: 'i2', status: ItemStatus.naoTem),
      ],
    );

    expect(find.text('Item i1'), findsNothing);
    expect(find.text('Item i2'), findsOneWidget);
  });

  testWidgets('tocar em item OFF chama atualizarStatus (falta -> no carrinho)',
      (tester) async {
    final calls = await _pumpMercado(
      tester,
      itens: [_itemOff(id: 'i1', status: ItemStatus.naoTem)],
    );

    await tester.tap(find.text('Item i1'));
    await tester.pump();

    expect(calls.statusCalls, hasLength(1));
    expect(calls.statusCalls.single.itemId, 'i1');
    expect(calls.statusCalls.single.statusAnterior, ItemStatus.naoTem);
    expect(calls.statusCalls.single.novoStatus, ItemStatus.noCarrinho);
    expect(calls.marcarNoCarrinhoCalls, isEmpty);
  });

  testWidgets(
      'tocar em item ON chama marcarNoCarrinho, não atualizarStatus (status é '
      'derivado, nunca ciclado manualmente)', (tester) async {
    final calls = await _pumpMercado(
      tester,
      itens: [_itemOn(id: 'i1', quantidade: 0, estoqueMinimo: 2)],
    );

    await tester.tap(find.text('Item i1'));
    await tester.pump();

    expect(calls.marcarNoCarrinhoCalls, hasLength(1));
    expect(calls.marcarNoCarrinhoCalls.single.itemId, 'i1');
    expect(calls.marcarNoCarrinhoCalls.single.noCarrinho, isTrue);
    expect(calls.statusCalls, isEmpty);
  });

  testWidgets(
      '"Atualizar dispensa" fecha o carrinho passando a mistura de itens ON '
      'e OFF atualmente marcados como no carrinho', (tester) async {
    final offNoCarrinho = _itemOff(id: 'off1', status: ItemStatus.noCarrinho);
    final onNoCarrinho = _itemOn(
      id: 'on1',
      quantidade: 0,
      estoqueMinimo: 2,
      noCarrinho: true,
    );
    final onForaDoCarrinho =
        _itemOn(id: 'on2', quantidade: 0, estoqueMinimo: 2);

    final calls = await _pumpMercado(
      tester,
      itens: [offNoCarrinho, onNoCarrinho, onForaDoCarrinho],
    );

    await tester.tap(find.textContaining('Atualizar dispensa'));
    await tester.pump();

    expect(calls.loteCalls, hasLength(1));
    final itensNoLote = calls.loteCalls.single;
    expect(itensNoLote.map((i) => i.id).toSet(), {'off1', 'on1'});
  });

  testWidgets('lista vazia mostra o empty state', (tester) async {
    await _pumpMercado(tester, itens: []);

    expect(find.text('Nada para comprar'), findsOneWidget);
  });
}
