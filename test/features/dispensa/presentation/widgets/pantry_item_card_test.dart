import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/dispensa/domain/models/pantry_item.dart';
import 'package:domo/features/dispensa/presentation/providers/dispensa_controller.dart';
import 'package:domo/features/dispensa/presentation/widgets/pantry_item_card.dart';
import 'package:domo/l10n/app_localizations.dart';

/// Records every `atualizarStatus` call instead of touching
/// `dispensaRepositoryProvider`/`authStateProvider` — keeps this a pure
/// widget-level smoke test of "does tapping the chip call the controller
/// with the right params", not an integration test of the whole stack.
class _RecordingDispensaController extends DispensaController {
  final calls = <({String casaId, String itemId, ItemStatus statusAnterior, ItemStatus novoStatus})>[];
  final quantidadeCalls = <({String casaId, String itemId, int quantidade, int estoqueMinimo})>[];

  @override
  FutureOr<void> build() {}

  @override
  Future<void> atualizarStatus({
    required String casaId,
    required String itemId,
    required ItemStatus statusAnterior,
    required ItemStatus novoStatus,
  }) async {
    calls.add((
      casaId: casaId,
      itemId: itemId,
      statusAnterior: statusAnterior,
      novoStatus: novoStatus,
    ));
  }

  @override
  Future<void> atualizarQuantidade({
    required String casaId,
    required String itemId,
    required int quantidade,
    required int estoqueMinimo,
  }) async {
    quantidadeCalls.add((
      casaId: casaId,
      itemId: itemId,
      quantidade: quantidade,
      estoqueMinimo: estoqueMinimo,
    ));
  }
}

PantryItem _item({required ItemStatus status}) => PantryItem(
      id: 'item1',
      casaId: 'casa1',
      nome: 'Leite integral',
      categoria: 'Laticínios',
      status: status,
      atualizadoEm: DateTime(2026, 1, 1),
      atualizadoPor: 'u1',
    );

PantryItem _itemComEstoque({
  required int quantidade,
  required int estoqueMinimo,
}) =>
    PantryItem(
      id: 'item1',
      casaId: 'casa1',
      nome: 'Leite integral',
      categoria: 'Laticínios',
      status: PantryItem.statusPorQuantidade(quantidade, estoqueMinimo),
      atualizadoEm: DateTime(2026, 1, 1),
      atualizadoPor: 'u1',
      controlaEstoque: true,
      quantidade: quantidade,
      estoqueMinimo: estoqueMinimo,
    );

Future<void> _pumpCard(
  WidgetTester tester, {
  required PantryItem item,
  required _RecordingDispensaController controller,
  VoidCallback? onTap,
  VoidCallback? onDismiss,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dispensaControllerProvider.overrideWith(() => controller),
      ],
      child: MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: PantryItemCard(
            item: item,
            onTap: onTap ?? () {},
            onDismiss: onDismiss ?? () {},
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renderiza sem crash e mostra nome + status do item',
      (tester) async {
    await _pumpCard(
      tester,
      item: _item(status: ItemStatus.naoTem),
      controller: _RecordingDispensaController(),
    );

    expect(find.text('Leite integral'), findsOneWidget);
    expect(find.text('Falta'), findsOneWidget);
  });

  testWidgets(
      'tocar no chip de status (item "tem") chama atualizarStatus com tem -> naoTem',
      (tester) async {
    final controller = _RecordingDispensaController();
    await _pumpCard(
      tester,
      item: _item(status: ItemStatus.tem),
      controller: controller,
    );

    await tester.tap(find.text('Temos'));
    await tester.pump();

    expect(controller.calls, hasLength(1));
    final call = controller.calls.single;
    expect(call.casaId, 'casa1');
    expect(call.itemId, 'item1');
    expect(call.statusAnterior, ItemStatus.tem);
    expect(call.novoStatus, ItemStatus.naoTem);
  });

  testWidgets(
      'tocar no chip de status (item "falta") chama atualizarStatus com naoTem -> tem',
      (tester) async {
    final controller = _RecordingDispensaController();
    await _pumpCard(
      tester,
      item: _item(status: ItemStatus.naoTem),
      controller: controller,
    );

    await tester.tap(find.text('Falta'));
    await tester.pump();

    expect(controller.calls, hasLength(1));
    expect(controller.calls.single.statusAnterior, ItemStatus.naoTem);
    expect(controller.calls.single.novoStatus, ItemStatus.tem);
  });

  testWidgets('tocar no corpo do card (fora do chip) dispara onTap, não o chip',
      (tester) async {
    var tapped = false;
    final controller = _RecordingDispensaController();
    await _pumpCard(
      tester,
      item: _item(status: ItemStatus.tem),
      controller: controller,
      onTap: () => tapped = true,
    );

    await tester.tap(find.text('Leite integral'));
    await tester.pump();

    expect(tapped, isTrue);
    expect(controller.calls, isEmpty);
  });

  testWidgets(
      'tocar perto da borda da zona de status (não em cima do texto) ainda '
      'chama atualizarStatus, não o onTap de editar — regressão do bug real '
      'reportado (zona de toque pequena demais fazia cair no edit)',
      (tester) async {
    var tapped = false;
    final controller = _RecordingDispensaController();
    await _pumpCard(
      tester,
      item: _item(status: ItemStatus.tem),
      controller: controller,
      onTap: () => tapped = true,
    );

    final zoneFinder = find.byKey(const ValueKey('status-toggle-item1'));
    final zoneRect = tester.getRect(zoneFinder);
    // Centro vertical (dentro do Material, que só exclui 8px de padding em
    // cima/embaixo), 8px da borda esquerda — dentro da zona clicável, mas
    // fora do texto "Temos", que fica centralizado horizontalmente.
    await tester.tapAt(
      zoneRect.topLeft + Offset(8, zoneRect.height / 2),
    );
    await tester.pump();

    expect(controller.calls, hasLength(1));
    expect(controller.calls.single.statusAnterior, ItemStatus.tem);
    expect(controller.calls.single.novoStatus, ItemStatus.naoTem);
    expect(tapped, isFalse);
  });

  group('item com controle de quantidade (ON-mode)', () {
    testWidgets(
        'mostra quantidade e estoque mínimo em vez do chip de status manual',
        (tester) async {
      await _pumpCard(
        tester,
        item: _itemComEstoque(quantidade: 3, estoqueMinimo: 2),
        controller: _RecordingDispensaController(),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('mín 2'), findsOneWidget);
      // Não deve haver zona de toggle manual de status para um item ON.
      expect(find.byKey(const ValueKey('status-toggle-item1')), findsNothing);
      expect(find.byKey(const ValueKey('quantity-zone-item1')), findsOneWidget);
    });

    testWidgets('tocar em "+" chama atualizarQuantidade com quantidade+1',
        (tester) async {
      final controller = _RecordingDispensaController();
      await _pumpCard(
        tester,
        item: _itemComEstoque(quantidade: 3, estoqueMinimo: 2),
        controller: controller,
      );

      await tester.tap(find.byKey(const ValueKey('quantity-plus-item1')));
      await tester.pump();

      expect(controller.quantidadeCalls, hasLength(1));
      final call = controller.quantidadeCalls.single;
      expect(call.casaId, 'casa1');
      expect(call.itemId, 'item1');
      expect(call.quantidade, 4);
      expect(call.estoqueMinimo, 2);
    });

    testWidgets('tocar em "-" chama atualizarQuantidade com quantidade-1',
        (tester) async {
      final controller = _RecordingDispensaController();
      await _pumpCard(
        tester,
        item: _itemComEstoque(quantidade: 3, estoqueMinimo: 2),
        controller: controller,
      );

      await tester.tap(find.byKey(const ValueKey('quantity-minus-item1')));
      await tester.pump();

      expect(controller.quantidadeCalls, hasLength(1));
      expect(controller.quantidadeCalls.single.quantidade, 2);
    });

    testWidgets('não deixa a quantidade cair abaixo de zero', (tester) async {
      final controller = _RecordingDispensaController();
      await _pumpCard(
        tester,
        item: _itemComEstoque(quantidade: 0, estoqueMinimo: 1),
        controller: controller,
      );

      await tester.tap(find.byKey(const ValueKey('quantity-minus-item1')));
      await tester.pump();

      expect(controller.quantidadeCalls, isEmpty);
    });

    testWidgets('tocar no corpo do card ainda abre a edição (onTap)',
        (tester) async {
      var tapped = false;
      await _pumpCard(
        tester,
        item: _itemComEstoque(quantidade: 3, estoqueMinimo: 2),
        controller: _RecordingDispensaController(),
        onTap: () => tapped = true,
      );

      await tester.tap(find.text('Leite integral'));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
