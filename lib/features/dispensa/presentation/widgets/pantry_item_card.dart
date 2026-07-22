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
      // Two independent tap zones side by side, not one big InkWell with a
      // tiny GestureDetector nested inside it — the old layout made the
      // status chip's hit area much smaller than the row's, so a tap aimed
      // at the chip regularly landed on the row's onTap (edit) instead. See
      // docs/DESIGN.md for the before/after on this.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      _StatusDot(status: item.status),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.nome,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isTem
                                ? theme.colorScheme.onSurface
                                    .withValues(alpha: 0.45)
                                : null,
                            decoration:
                                isTem ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            item.controlaEstoque
                ? _QuantityZone(
                    key: ValueKey('quantity-zone-${item.id}'),
                    item: item,
                  )
                : _StatusToggleZone(
                    key: ValueKey('status-toggle-${item.id}'),
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

/// ON-mode (quantity-controlled) items' zone: replaces the manual status
/// toggle with a compact quantity stepper + minimum-stock caption. Per the
/// product spec the user never manually cycles status for ON items — status
/// is DERIVED from `quantidade`/`estoqueMinimo` (`PantryItem.emFalta`) — so
/// this zone's only interaction is adjusting the quantity, wired straight to
/// `DispensaController.atualizarQuantidade`. Reuses the same tonal
/// container/on-container recipe as `_StatusToggleZone` (keyed off the
/// item's derived `status`) so an ON item reads with the same visual weight
/// as an OFF item's chip, just with different content.
class _QuantityZone extends ConsumerWidget {
  const _QuantityZone({super.key, required this.item});
  final PantryItem item;

  static const _width = 108.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final quantidade = item.quantidade ?? 0;
    final estoqueMinimo = item.estoqueMinimo ?? 0;
    // Grab the notifier once at build time (same pattern as
    // `PantryItemCard.build`'s `controller` local), not lazily via
    // `ref.read(...)` inside the tap handler: `dispensaControllerProvider` is
    // auto-dispose and nothing here keeps it alive between builds, so a
    // `ref.read` at tap time can re-create the provider against the SAME
    // already-initialized notifier instance an `overrideWith` factory
    // returns in tests, which crashes. Holding the already-resolved instance
    // sidesteps a second provider lookup entirely.
    final controller = ref.read(dispensaControllerProvider.notifier);

    final (bgColor, textColor) = item.status == ItemStatus.naoTem
        ? (isDark
            ? (
                AppColors.statusFaltaContainerDark,
                AppColors.onStatusFaltaContainerDark
              )
            : (
                AppColors.statusFaltaContainerLight,
                AppColors.onStatusFaltaContainerLight
              ))
        : (isDark
            ? (
                AppColors.statusTemContainerDark,
                AppColors.onStatusTemContainerDark
              )
            : (
                AppColors.statusTemContainerLight,
                AppColors.onStatusTemContainerLight
              ));

    void ajustar(int delta) {
      final nova = quantidade + delta;
      if (nova < 0) return;
      controller.atualizarQuantidade(
            casaId: item.casaId,
            itemId: item.id,
            quantidade: nova,
            estoqueMinimo: estoqueMinimo,
          );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8).copyWith(right: 16),
      child: SizedBox(
        width: _width,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _StepperButton(
                      key: ValueKey('quantity-minus-${item.id}'),
                      icon: Icons.remove_rounded,
                      color: textColor,
                      onTap: () => ajustar(-1),
                    ),
                    SizedBox(
                      width: 28,
                      child: Text(
                        '$quantidade',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StepperButton(
                      key: ValueKey('quantity-plus-${item.id}'),
                      icon: Icons.add_rounded,
                      color: textColor,
                      onTap: () => ajustar(1),
                    ),
                  ],
                ),
                Text(
                  'mín $estoqueMinimo',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  const _StepperButton({
    super.key,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

/// The status toggle's own tap zone — a fixed-width column next to the name
/// zone, not a small label floating inside the row's InkWell. Colored per
/// docs/DESIGN.md §1.1/§4.1 to fix a real contrast bug: the previous
/// implementation rendered the saturated status color as text directly over
/// that *same* color at 12–15% alpha, which lands at 3.6–4.4:1 (below the
/// 4.5:1 a ~12px label needs). Fixed by using a dedicated container/
/// on-container hex pair per status (same recipe as
/// `primaryContainer`/`tertiaryContainer`), landing 9–11:1.
class _StatusToggleZone extends StatelessWidget {
  const _StatusToggleZone({super.key, required this.status, required this.onTap});
  final ItemStatus status;
  final VoidCallback onTap;

  static const _width = 84.0;

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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8).copyWith(right: 16),
      child: SizedBox(
        width: _width,
        child: Material(
          color: bgColor,
          // Squared-off "label tag" shape, not a full pill — docs/DESIGN.md
          // §3: the single biggest tactile differentiator from Dindin.
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
            child: Center(
              child: Text(
                status.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: textColor,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
