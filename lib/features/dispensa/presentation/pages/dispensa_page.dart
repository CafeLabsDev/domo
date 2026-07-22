import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../casa/presentation/providers/casa_provider.dart';
import '../../domain/constants.dart';
import '../../domain/models/pantry_item.dart';
import '../providers/dispensa_controller.dart';
import '../providers/dispensa_provider.dart';
import '../widgets/add_edit_item_sheet.dart';
import '../widgets/pantry_item_card.dart';
import '../../../../shared/widgets/domo_error_state.dart';
import '../../../../shared/widgets/domo_leading_logo.dart' show DomoPageTitle;

class DispensaPage extends ConsumerWidget {
  const DispensaPage({super.key});

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
        return _DispensaContent(
          casaId: casa.id,
          ordemCategorias: casa.ordemCategorias,
        );
      },
    );
  }
}

class _DispensaContent extends ConsumerWidget {
  const _DispensaContent({required this.casaId, this.ordemCategorias});

  final String casaId;
  final List<String>? ordemCategorias;

  void _openSheet(BuildContext context, {PantryItem? item}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => AddEditItemSheet(casaId: casaId, item: item),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itensAsync = ref.watch(itensProvider(casaId));
    final controller = ref.read(dispensaControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: DomoPageTitle('Dispensa'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openSheet(context),
        child: const Icon(Icons.add),
      ),
      body: itensAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => DomoErrorState(
          title: 'Não foi possível carregar sua dispensa.',
          onRetry: () => ref.invalidate(itensProvider(casaId)),
        ),
        data: (todos) {
          final itens =
              todos.where((i) => !i.estaNoCarrinho).toList();
          if (itens.isEmpty) {
            return _EmptyState(onAdd: () => _openSheet(context));
          }
          return _ItensGrouped(
            itens: itens,
            ordemCategorias: ordemCategorias,
            onEdit: (item) => _openSheet(context, item: item),
            onDelete: (item) => controller.deletarItem(
              casaId: item.casaId,
              itemId: item.id,
            ),
          );
        },
      ),
    );
  }
}

class _ItensGrouped extends StatelessWidget {
  const _ItensGrouped({
    required this.itens,
    required this.onEdit,
    required this.onDelete,
    this.ordemCategorias,
  });

  final List<PantryItem> itens;
  final List<String>? ordemCategorias;
  final void Function(PantryItem) onEdit;
  final void Function(PantryItem) onDelete;

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
    // House's custom category order (feature 3), falling back to the fixed
    // kDispensaCategorias order — then keep only categories that actually
    // have items today, in that order.
    final categories = categoriasOrdenadas(ordemCategorias)
        .where(grouped.containsKey)
        .toList();
    final theme = Theme.of(context);

    return ListView.builder(
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
              (item) => PantryItemCard(
                key: ValueKey(item.id),
                item: item,
                onTap: () => onEdit(item),
                onDismiss: () => onDelete(item),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

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
              Icons.kitchen_outlined,
              size: 72,
              color: theme.colorScheme.primary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Sua dispensa está vazia',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Adicione itens para controlar o que você tem em casa.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar item'),
            ),
          ],
        ),
      ),
    );
  }
}
