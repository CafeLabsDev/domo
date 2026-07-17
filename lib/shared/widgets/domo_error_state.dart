import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

/// Friendly, actionable error state — replaces raw `Text('Erro: $e')`
/// across the app (docs/DESIGN.md §4.7). Shows a warning icon, a
/// situation-specific Portuguese title (never the raw exception string), a
/// reassuring subtitle, and a "Tentar novamente" action that the caller
/// wires to `ref.invalidate(...)` on the relevant provider.
class DomoErrorState extends StatelessWidget {
  const DomoErrorState({
    super.key,
    required this.title,
    this.message =
        'Verifique sua conexão com a internet e tente novamente.',
    required this.onRetry,
  });

  final String title;
  final String message;
  final VoidCallback onRetry;

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
              Icons.error_outline_rounded,
              size: 44,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}
