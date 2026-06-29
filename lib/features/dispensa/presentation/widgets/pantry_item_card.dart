import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
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
        color: AppColors.error,
        child: const Icon(Icons.delete_outline, color: Colors.white),
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
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
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
    final color = switch (status) {
      ItemStatus.tem => AppColors.statusHave,
      ItemStatus.naoTem => AppColors.statusNeed,
      ItemStatus.noCarrinho => AppColors.statusInCart,
    };
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.onTap});
  final ItemStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (color, bgColor) = switch (status) {
      ItemStatus.tem => (
          AppColors.statusHave,
          AppColors.statusHave.withValues(alpha: 0.12),
        ),
      ItemStatus.naoTem => (
          AppColors.statusNeed,
          AppColors.statusNeed.withValues(alpha: 0.12),
        ),
      ItemStatus.noCarrinho => (
          AppColors.statusInCart,
          AppColors.statusInCart.withValues(alpha: 0.15),
        ),
    };

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.4)),
        ),
        child: Text(
          status.label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
