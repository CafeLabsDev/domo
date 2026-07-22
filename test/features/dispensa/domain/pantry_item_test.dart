import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/dispensa/domain/models/pantry_item.dart';

/// Direct unit coverage of `PantryItem`'s pure derivation logic. This is the
/// single source both the repository writes and the Firestore rule (see
/// `firestore.rules` / `docs/BACKEND.md`) are supposed to agree with — so the
/// boundary case (`quantidade == estoqueMinimo`) is the highest-value case to
/// pin here: the rules suite asserts the SAME boundary server-side
/// (`itens quantity control > create an ON-mode item directly`), so a test
/// here is a cheap regression guard that the two sides never drift apart.
void main() {
  group('PantryItem.statusPorQuantidade', () {
    test('quantidade abaixo do mínimo => naoTem (em falta)', () {
      expect(
        PantryItem.statusPorQuantidade(0, 2),
        ItemStatus.naoTem,
      );
    });

    test(
        'quantidade EXATAMENTE igual ao mínimo => naoTem (boundary: <=, não <)',
        () {
      expect(
        PantryItem.statusPorQuantidade(1, 1),
        ItemStatus.naoTem,
      );
    });

    test('quantidade acima do mínimo => tem', () {
      expect(
        PantryItem.statusPorQuantidade(3, 2),
        ItemStatus.tem,
      );
    });

    test('mínimo zero e quantidade zero (boundary em zero) => naoTem', () {
      expect(
        PantryItem.statusPorQuantidade(0, 0),
        ItemStatus.naoTem,
      );
    });

    test('mínimo zero e quantidade positiva => tem', () {
      expect(
        PantryItem.statusPorQuantidade(1, 0),
        ItemStatus.tem,
      );
    });
  });

  PantryItem itemOn({
    required int quantidade,
    required int estoqueMinimo,
    bool noCarrinho = false,
  }) =>
      PantryItem(
        id: 'i1',
        casaId: 'casa1',
        nome: 'Item',
        categoria: 'Cat',
        status: PantryItem.statusPorQuantidade(quantidade, estoqueMinimo),
        atualizadoEm: DateTime(2026, 1, 1),
        atualizadoPor: 'u1',
        controlaEstoque: true,
        quantidade: quantidade,
        estoqueMinimo: estoqueMinimo,
        noCarrinho: noCarrinho,
      );

  PantryItem itemOff({required ItemStatus status}) => PantryItem(
        id: 'i1',
        casaId: 'casa1',
        nome: 'Item',
        categoria: 'Cat',
        status: status,
        atualizadoEm: DateTime(2026, 1, 1),
        atualizadoPor: 'u1',
      );

  group('PantryItem.emFalta', () {
    test('ON-mode no boundary (quantidade == estoqueMinimo) conta como em falta',
        () {
      expect(itemOn(quantidade: 1, estoqueMinimo: 1).emFalta, isTrue);
    });

    test('ON-mode acima do mínimo não conta como em falta', () {
      expect(itemOn(quantidade: 2, estoqueMinimo: 1).emFalta, isFalse);
    });

    test('OFF-mode naoTem conta como em falta', () {
      expect(itemOff(status: ItemStatus.naoTem).emFalta, isTrue);
    });

    test('OFF-mode tem/noCarrinho não contam como em falta', () {
      expect(itemOff(status: ItemStatus.tem).emFalta, isFalse);
      expect(itemOff(status: ItemStatus.noCarrinho).emFalta, isFalse);
    });
  });

  group('PantryItem.estaNoCarrinho', () {
    test('ON-mode usa a flag noCarrinho, independente do status derivado', () {
      // Em falta E marcado no carrinho.
      expect(
        itemOn(quantidade: 0, estoqueMinimo: 2, noCarrinho: true)
            .estaNoCarrinho,
        isTrue,
      );
      // Com estoque suficiente mas ainda marcado no carrinho (não foi
      // fechado ainda) continua contando como no carrinho.
      expect(
        itemOn(quantidade: 5, estoqueMinimo: 2, noCarrinho: true)
            .estaNoCarrinho,
        isTrue,
      );
      expect(
        itemOn(quantidade: 0, estoqueMinimo: 2, noCarrinho: false)
            .estaNoCarrinho,
        isFalse,
      );
    });

    test('OFF-mode usa o status noCarrinho do enum', () {
      expect(itemOff(status: ItemStatus.noCarrinho).estaNoCarrinho, isTrue);
      expect(itemOff(status: ItemStatus.naoTem).estaNoCarrinho, isFalse);
      expect(itemOff(status: ItemStatus.tem).estaNoCarrinho, isFalse);
    });
  });
}
