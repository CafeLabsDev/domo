import 'package:flutter_test/flutter_test.dart';

import 'package:domo/features/dispensa/domain/constants.dart';

void main() {
  group('categoriasOrdenadas', () {
    test('retorna kDispensaCategorias quando ordemCategorias é null', () {
      expect(categoriasOrdenadas(null), kDispensaCategorias);
    });

    test('retorna kDispensaCategorias quando ordemCategorias está vazia', () {
      expect(categoriasOrdenadas([]), kDispensaCategorias);
    });

    test('respeita a ordem customizada da casa quando presente', () {
      final custom = [
        'Bebidas',
        'Outros',
        'Frutas e Verduras',
        'Laticínios',
        'Carnes e Peixes',
        'Padaria',
        'Limpeza',
        'Higiene e Cuidados',
      ];
      expect(categoriasOrdenadas(custom), custom);
    });

    test(
        'ignora strings desconhecidas na ordem salva e mantém as categorias '
        'fixas conhecidas', () {
      final custom = ['Bebidas', 'Categoria Removida', 'Outros'];
      final result = categoriasOrdenadas(custom);

      expect(result.contains('Categoria Removida'), isFalse);
      expect(result.first, 'Bebidas');
      expect(result[1], 'Outros');
      // As categorias fixas que não estavam na ordem salva aparecem no final,
      // na ordem de kDispensaCategorias.
      expect(result.length, kDispensaCategorias.length);
      expect(result.toSet(), kDispensaCategorias.toSet());
    });
  });
}
