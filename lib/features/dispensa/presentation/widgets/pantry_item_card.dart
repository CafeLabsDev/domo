import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../domain/models/pantry_item.dart';
import '../providers/dispensa_controller.dart';

class PantryItemCard extends ConsumerWidget {
  const PantryItemCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDismiss,
  });

  final PantryItem item;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.read(dispensaControllerProvider.notifier);
    final theme = Theme.of(context);
    final isTem = item.status == ItemStatus.tem;

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: theme.colorScheme.error,
        child: Icon(Icons.delete_outline, color: theme.colorScheme.onError),
      ),
      confirmDismiss: (_) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Remover item'),
          content: Text('Deseja remover "${item.nome}" da dispensa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: const Text('Remover'),
            ),
          ],
        ),
      ),
      onDismissed: (_) => onDismiss(),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              _StatusDot(status: item.status),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.nome,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: isTem
                        ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
                        : null,
                    decoration: isTem ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _StatusChip(
                status: item.status,
                onTap: () => controller.atualizarStatus(
                  casaId: item.casaId,
                  itemId: item.id,
                  statusAnterior: item.status,
                  novoStatus: item.status == ItemStatus.tem
                      ? ItemStatus.naoTem
                      : ItemStatus.tem,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});
  final ItemStatus status;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = switch (status) {
      ItemStatus.tem => isDark ? AppColors.statusTemDark : AppColors.statusTemLight,
      ItemStatus.naoTem =>
        isDark ? AppColors.statusFaltaDark : AppColors.statusFaltaLight,
      ItemStatus.noCarrinho =>
        isDark ? AppColors.statusCarrinhoDark : AppColors.statusCarrinhoLight,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// Everyday tonal chip — recolored per docs/DESIGN.md §1.1/§4.1 to fix a
/// real contrast bug: the previous implementation rendered the saturated
/// status color as text directly over that *same* color at 12–15% alpha,
/// which lands at 3.6–4.4:1 (below the 4.5:1 a ~12px label needs). Fixed by
/// using a dedicated container/on-container hex pair per status (same
/// recipe as `primaryContainer`/`tertiaryContainer`), landing 9–11:1.
class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.onTap});
  final ItemStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final (bgColor, textColor) = switch (status) {
      ItemStatus.tem => isDark
          ? (AppColors.statusTemContainerDark, AppColors.onStatusTemContainerDark)
          : (
              AppColors.statusTemContainerLight,
              AppColors.onStatusTemContainerLight
            ),
      ItemStatus.naoTem => isDark
          ? (
              AppColors.statusFaltaContainerDark,
              AppColors.onStatusFaltaContainerDark
            )
          : (
              AppColors.statusFaltaContainerLight,
              AppColors.onStatusFaltaContainerLight
            ),
      ItemStatus.noCarrinho => isDark
          ? (
              AppColors.statusCarrinhoContainerDark,
              AppColors.onStatusCarrinhoContainerDark
            )
          : (
              AppColors.statusCarrinhoContainerLight,
              AppColors.onStatusCarrinhoContainerLight
            ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          // Squared-off "label tag" shape, not a full pill — docs/DESIGN.md
          // §3: the single biggest tactile differentiator from Dindin.
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
        ),
        child: Text(
          status.label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: textColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
