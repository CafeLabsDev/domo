import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/casa/domain/models/casa_model.dart';
import 'package:domo/features/casa/presentation/providers/casa_provider.dart';
import 'package:domo/features/dispensa/domain/models/pantry_item.dart';
import 'package:domo/features/dispensa/presentation/pages/dispensa_page.dart';
import 'package:domo/features/dispensa/presentation/providers/dispensa_provider.dart';

final _casa = CasaModel(
  id: 'casa1',
  nome: 'Casa da Família',
  codigo: 'ABC123',
  criadoPor: 'u1',
  criadoEm: DateTime(2026, 1, 1),
);

void main() {
  testWidgets('mostra o estado vazio quando a dispensa não tem itens ativos',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          casaDoUsuarioProvider.overrideWith((ref) => Stream.value(_casa)),
          itensProvider(_casa.id)
              .overrideWith((ref) => Stream.value(<PantryItem>[])),
        ],
        child: const MaterialApp(home: DispensaPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sua dispensa está vazia'), findsOneWidget);
    expect(find.text('Adicionar item'), findsOneWidget);
  });

  testWidgets(
      'todos os itens "no carrinho" também contam como dispensa vazia (aba própria)',
      (tester) async {
    final item = PantryItem(
      id: 'item1',
      casaId: _casa.id,
      nome: 'Arroz',
      categoria: 'Grãos',
      status: ItemStatus.noCarrinho,
      atualizadoEm: DateTime(2026, 1, 1),
      atualizadoPor: 'u1',
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          casaDoUsuarioProvider.overrideWith((ref) => Stream.value(_casa)),
          itensProvider(_casa.id).overrideWith((ref) => Stream.value([item])),
        ],
        child: const MaterialApp(home: DispensaPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sua dispensa está vazia'), findsOneWidget);
  });

  testWidgets('tocar em "Adicionar item" abre a sheet de novo item',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          casaDoUsuarioProvider.overrideWith((ref) => Stream.value(_casa)),
          itensProvider(_casa.id)
              .overrideWith((ref) => Stream.value(<PantryItem>[])),
        ],
        child: const MaterialApp(home: DispensaPage()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Adicionar item'));
    await tester.pumpAndSettle();

    expect(find.text('Novo item'), findsOneWidget);
  });
}
