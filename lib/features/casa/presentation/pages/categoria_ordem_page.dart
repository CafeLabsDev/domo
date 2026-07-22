import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/domo_error_state.dart';
import '../../../dispensa/domain/constants.dart';
import '../providers/casa_controller.dart';
import '../providers/casa_provider.dart';

/// Feature 3 — lets an active member reorder the 8 fixed dispensa categories
/// for their house. Reached from `CasaPage`'s app bar (a "reorder" icon next
/// to the invite-code share action) — Casa is the natural home for
/// house-wide settings, and this is discoverable without competing with the
/// members list for attention. Uses Flutter's own `ReorderableListView`
/// (drag handle per row) rather than a hand-rolled drag implementation.
class CategoriaOrdemPage extends ConsumerWidget {
  const CategoriaOrdemPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casaAsync = ref.watch(casaDoUsuarioProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.categoryOrderTitle)),
      body: casaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => DomoErrorState(
          title: l10n.couldNotLoadHouse,
          onRetry: () => ref.invalidate(casaDoUsuarioProvider),
        ),
        data: (casa) {
          if (casa == null) return const SizedBox.shrink();
          return _CategoriaOrdemBody(
            casaId: casa.id,
            ordemInicial: categoriasOrdenadas(casa.ordemCategorias),
          );
        },
      ),
    );
  }
}

class _CategoriaOrdemBody extends ConsumerStatefulWidget {
  const _CategoriaOrdemBody({
    required this.casaId,
    required this.ordemInicial,
  });

  final String casaId;
  final List<String> ordemInicial;

  @override
  ConsumerState<_CategoriaOrdemBody> createState() =>
      _CategoriaOrdemBodyState();
}

class _CategoriaOrdemBodyState extends ConsumerState<_CategoriaOrdemBody> {
  late List<String> _ordem;
  bool _alterado = false;

  @override
  void initState() {
    super.initState();
    _ordem = List.of(widget.ordemInicial);
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final categoria = _ordem.removeAt(oldIndex);
      _ordem.insert(newIndex, categoria);
      _alterado = true;
    });
  }

  Future<void> _salvar() async {
    await ref
        .read(casaControllerProvider.notifier)
        .atualizarOrdemCategorias(widget.casaId, _ordem);
    if (!mounted) return;
    final erro = ref.read(casaControllerProvider).hasError;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(
            erro ? l10n.saveOrderFailed : l10n.orderSaved,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    if (!erro) setState(() => _alterado = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isLoading = ref.watch(casaControllerProvider).isLoading;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Text(
            l10n.categoryOrderInstructions,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ReorderableListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            buildDefaultDragHandles: false,
            itemCount: _ordem.length,
            onReorderItem: _onReorder,
            itemBuilder: (context, index) {
              final categoria = _ordem[index];
              return Card(
                key: ValueKey(categoria),
                margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: ListTile(
                  title: Text(categoriaLabel(l10n, categoria)),
                  trailing: ReorderableDragStartListener(
                    index: index,
                    child: const Icon(Icons.drag_handle_rounded),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            top: AppSpacing.sm,
            bottom: MediaQuery.paddingOf(context).bottom + AppSpacing.md,
          ),
          child: FilledButton(
            onPressed: (_alterado && !isLoading) ? _salvar : null,
            child: isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
                    ),
                  )
                : Text(l10n.saveOrderButton),
          ),
        ),
      ],
    );
  }
}
