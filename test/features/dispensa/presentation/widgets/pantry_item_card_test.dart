import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/dispensa/domain/models/pantry_item.dart';
import 'package:domo/features/dispensa/presentation/providers/dispensa_controller.dart';
import 'package:domo/features/dispensa/presentation/widgets/pantry_item_card.dart';

/// Records every `atualizarStatus` call instead of touching
/// `dispensaRepositoryProvider`/`authStateProvider` — keeps this a pure
/// widget-level smoke test of "does tapping the chip call the controller
/// with the right params", not an integration test of the whole stack.
class _RecordingDispensaController extends DispensaController {
  final calls = <({String casaId, String itemId, ItemStatus statusAnterior, ItemStatus novoStatus})>[];

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
}
