import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../casa/presentation/providers/casa_provider.dart';
import '../../../dispensa/domain/models/pantry_item.dart';
import '../../../dispensa/presentation/providers/dispensa_controller.dart';
import '../../../dispensa/presentation/providers/dispensa_provider.dart';

class MercadoPage extends ConsumerWidget {
  const MercadoPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casaAsync = ref.watch(casaDoUsuarioProvider);

    return casaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro: $e')),
      ),
      data: (casa) {
        if (casa == null) return const Scaffold(body: SizedBox.shrink());
        return _MercadoContent(casaId: casa.id);
      },
    );
  }
}

class _MercadoContent extends ConsumerWidget {
  const _MercadoContent({required this.casaId});

  final String casaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itensProvider(casaId));
    final controller = ref.read(dispensaControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Compras'),
        centerTitle: false,
      ),
      body: itensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Erro: $e')),
        data: (todos) {
          final itens = todos
              .where((i) => i.status == ItemStatus.noCarrinho)
              .toList();

          if (itens.isEmpty) return const _EmptyState();

          return _ListaDeCompras(
            itens: itens,
            onMarcarItem: (item) => controller.atualizarStatus(
              casaId: item.casaId,
              itemId: item.id,
              novoStatus: ItemStatus.tem,
            ),
            onMarcarTudo: () => controller.atualizarDispensaEmLote(
              casaId: casaId,
              itemIds: itens.map((i) => i.id).toList(),
            ),
          );
        },
      ),
    );
  }
}

class _ListaDeCompras extends StatelessWidget {
  const _ListaDeCompras({
    required this.itens,
    required this.onMarcarItem,
    required this.onMarcarTudo,
  });

  final List<PantryItem> itens;
  final void Function(PantryItem) onMarcarItem;
  final VoidCallback onMarcarTudo;

  Map<String, List<PantryItem>> _group(List<PantryItem> items) {
    final map = <String, List<PantryItem>>{};
    for (final item in items) {
      (map[item.categoria] ??= []).add(item);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = _group(itens);
    final categories = grouped.keys.toList()..sort();
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final categoria = categories[index];
              final items = grouped[categoria]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.lg,
                      AppSpacing.xs,
                    ),
                    child: Text(
                      categoria.toUpperCase(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ...items.map(
                    (item) => _MercadoItemTile(
                      item: item,
                      onTap: () => onMarcarItem(item),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _BotaoMarcarTudo(
          quantidade: itens.length,
          onPressed: onMarcarTudo,
        ),
      ],
    );
  }
}

class _MercadoItemTile extends StatelessWidget {
  const _MercadoItemTile({required this.item, required this.onTap});

  final PantryItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.statusInCart,
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.nome,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BotaoMarcarTudo extends StatelessWidget {
  const _BotaoMarcarTudo({
    required this.quantidade,
    required this.onPressed,
  });

  final int quantidade;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.check_circle_outline),
        label: Text(
          quantidade == 1
              ? 'Comprei o item — atualizar dispensa'
              : 'Comprei tudo ($quantidade itens) — atualizar dispensa',
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Carrinho vazio',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Na Dispensa, toque no chip de um item e mude para "No carrinho" para ele aparecer aqui.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
