import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../casa/presentation/providers/casa_provider.dart';
import '../../../dispensa/domain/models/pantry_item.dart';
import '../../../dispensa/presentation/providers/dispensa_controller.dart';
import '../../../dispensa/presentation/providers/dispensa_provider.dart';
import '../../../../shared/widgets/domo_error_state.dart';
import '../../../../shared/widgets/domo_leading_logo.dart' show DomoPageTitle;

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
        body: DomoErrorState(
          title: 'Não foi possível carregar sua casa.',
          onRetry: () => ref.invalidate(casaDoUsuarioProvider),
        ),
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
        title: DomoPageTitle('Lista de Compras'),
        centerTitle: false,
      ),
      body: itensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => DomoErrorState(
          title: 'Não foi possível carregar sua lista de compras.',
          onRetry: () => ref.invalidate(itensProvider(casaId)),
        ),
        data: (todos) {
          final itens = todos
              .where((i) =>
                  i.status == ItemStatus.naoTem ||
                  i.status == ItemStatus.noCarrinho)
              .toList();

          if (itens.isEmpty) return const _EmptyState();

          final noCarrinho =
              itens.where((i) => i.status == ItemStatus.noCarrinho).toList();

          return _ListaDeCompras(
            itens: itens,
            onToggleItem: (item) => controller.atualizarStatus(
              casaId: item.casaId,
              itemId: item.id,
              statusAnterior: item.status,
              novoStatus: item.status == ItemStatus.noCarrinho
                  ? ItemStatus.naoTem
                  : ItemStatus.noCarrinho,
            ),
            onAtualizarDispensa: noCarrinho.isEmpty
                ? null
                : () => controller.atualizarDispensaEmLote(
                      casaId: casaId,
                      itemIds: noCarrinho.map((i) => i.id).toList(),
                    ),
            quantidadeNoCarrinho: noCarrinho.length,
          );
        },
      ),
    );
  }
}

class _ListaDeCompras extends StatelessWidget {
  const _ListaDeCompras({
    required this.itens,
    required this.onToggleItem,
    required this.onAtualizarDispensa,
    required this.quantidadeNoCarrinho,
  });

  final List<PantryItem> itens;
  final void Function(PantryItem) onToggleItem;
  final VoidCallback? onAtualizarDispensa;
  final int quantidadeNoCarrinho;

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
                      onToggle: () => onToggleItem(item),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        _RodapeBotao(
          quantidade: quantidadeNoCarrinho,
          onPressed: onAtualizarDispensa,
        ),
      ],
    );
  }
}

class _MercadoItemTile extends StatelessWidget {
  const _MercadoItemTile({required this.item, required this.onToggle});

  final PantryItem item;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final noCarrinho = item.status == ItemStatus.noCarrinho;
    // statusCarrinho reuses the `tertiary` token (docs/DESIGN.md §1.1: "in
    // the cart" borrows the collective-action accent).
    final statusCarrinho =
        isDark ? AppColors.statusCarrinhoDark : AppColors.statusCarrinhoLight;
    final onStatusCarrinho = theme.colorScheme.onTertiary;

    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: noCarrinho ? statusCarrinho : Colors.transparent,
                border: Border.all(
                  color: noCarrinho ? statusCarrinho : theme.colorScheme.outline,
                  width: 2,
                ),
              ),
              child: noCarrinho
                  ? Icon(Icons.check, size: 14, color: onStatusCarrinho)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                item.nome,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: noCarrinho
                      ? theme.colorScheme.onSurface.withValues(alpha: 0.5)
                      : null,
                  decoration:
                      noCarrinho ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            if (noCarrinho)
              Text(
                'No carrinho',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: statusCarrinho,
                  fontWeight: FontWeight.w700,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RodapeBotao extends StatelessWidget {
  const _RodapeBotao({
    required this.quantidade,
    required this.onPressed,
  });

  final int quantidade;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final habilitado = onPressed != null;
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
        style: habilitado
            ? null
            : FilledButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                foregroundColor:
                    Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
              ),
        icon: const Icon(Icons.check_circle_outline),
        label: Text(
          habilitado
              ? (quantidade == 1
                  ? 'Atualizar dispensa (1 item)'
                  : 'Atualizar dispensa ($quantidade itens)')
              : 'Selecione itens para comprar',
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
              'Nada para comprar',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Quando um item da dispensa estiver "Em falta", ele aparecerá aqui para você marcar na lista.',
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
