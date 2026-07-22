import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/membro_model.dart';
import '../providers/casa_controller.dart';
import '../providers/casa_provider.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/domo_error_state.dart';
import '../../../../shared/widgets/domo_leading_logo.dart' show DomoPageTitle;

class CasaPage extends ConsumerWidget {
  const CasaPage({super.key});

  void _copiarCodigo(BuildContext context, String codigo) {
    final l10n = AppLocalizations.of(context)!;
    Clipboard.setData(ClipboardData(text: codigo));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(l10n.codeCopied),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _confirmarSaida(BuildContext context, WidgetRef ref, String casaId) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.leaveHouseTitle),
        content: Text(l10n.leaveHouseConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(casaControllerProvider.notifier).sairDaCasa(casaId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.leave),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(
    BuildContext context,
    WidgetRef ref,
    String casaId,
    String nomeCasa,
  ) {
    final isGoogleUser = FirebaseAuth.instance.currentUser?.providerData
            .any((p) => p.providerId == 'google.com') ??
        false;

    showDialog(
      context: context,
      builder: (_) => _ConfirmarDelecaoDialog(
        nomeCasa: nomeCasa,
        isGoogleUser: isGoogleUser,
        onConfirm: () =>
            ref.read(casaControllerProvider.notifier).deletarCasa(casaId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final casaAsync = ref.watch(casaDoUsuarioProvider);
    final l10n = AppLocalizations.of(context)!;

    return casaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: DomoErrorState(
          title: l10n.couldNotLoadHouse,
          onRetry: () => ref.invalidate(casaDoUsuarioProvider),
        ),
      ),
      data: (casa) {
        if (casa == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final membrosAsync = ref.watch(membrosProvider(casa.id));
        final currentUserId =
            ref.watch(authStateProvider).valueOrNull?.uid ?? '';
        final isAdmin = casa.criadoPor == currentUserId;

        return Scaffold(
          appBar: AppBar(
            title: DomoPageTitle(casa.nome),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: l10n.copyCodeTooltip,
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _copiarCodigo(context, casa.codigo),
              ),
              // Feature 3 — any active member (not admin-only) can reorder
              // the dispensa categories for the house; kept as its own icon
              // rather than inside the sair/deletar popup menu since it's
              // not a destructive/admin-gated action.
              IconButton(
                tooltip: l10n.reorderCategoriesTooltip,
                icon: const Icon(Icons.sort_rounded),
                onPressed: () => context.push('/casa/categorias'),
              ),
              PopupMenuButton<_MenuAcao>(
                onSelected: (acao) {
                  if (acao == _MenuAcao.sair) {
                    _confirmarSaida(context, ref, casa.id);
                  } else {
                    _confirmarExclusao(context, ref, casa.id, casa.nome);
                  }
                },
                itemBuilder: (_) => [
                  if (!isAdmin)
                    PopupMenuItem(
                      value: _MenuAcao.sair,
                      child: ListTile(
                        leading: const Icon(Icons.logout),
                        title: Text(l10n.leaveHouseTitle),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (isAdmin)
                    PopupMenuItem(
                      value: _MenuAcao.deletar,
                      child: ListTile(
                        leading: Icon(Icons.delete_forever,
                            color: Theme.of(context).colorScheme.error),
                        title: Text(
                          l10n.deleteHouseTitle,
                          style:
                              TextStyle(color: Theme.of(context).colorScheme.error),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              // Card do código de convite
              Container(
                margin: const EdgeInsets.all(AppSpacing.md),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.vpn_key_rounded,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.inviteCode,
                          style: Theme.of(context)
                              .textTheme
                              .labelMedium
                              ?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                        Text(
                          casa.codigo,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                letterSpacing: 6,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                                color: Theme.of(context)
                                    .colorScheme
                                    .onPrimaryContainer,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de membros
              Expanded(
                child: membrosAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => DomoErrorState(
                    title: l10n.couldNotLoadMembers,
                    onRetry: () => ref.invalidate(membrosProvider(casa.id)),
                  ),
                  data: (membros) {
                    final ativos = membros
                        .where((m) => m.status == MembroStatus.ativo)
                        .toList();
                    final pendentes = membros
                        .where((m) => m.status == MembroStatus.pendente)
                        .toList();

                    return ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                      ),
                      children: [
                        if (pendentes.isNotEmpty && isAdmin) ...[
                          _SectionHeader(
                            l10n.pendingApproval(pendentes.length),
                          ),
                          ...pendentes.map(
                            (m) => _MembroTile(
                              membro: m,
                              casaId: casa.id,
                              currentUserId: currentUserId,
                              isPending: true,
                              isAdmin: isAdmin,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                        ],
                        _SectionHeader(l10n.membersCount(ativos.length)),
                        ...ativos.map(
                          (m) => _MembroTile(
                            membro: m,
                            casaId: casa.id,
                            currentUserId: currentUserId,
                            isPending: false,
                            isAdmin: isAdmin,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

enum _MenuAcao { sair, deletar }

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _MembroTile extends ConsumerWidget {
  const _MembroTile({
    required this.membro,
    required this.casaId,
    required this.currentUserId,
    required this.isPending,
    required this.isAdmin,
  });

  final MembroModel membro;
  final String casaId;
  final String currentUserId;
  final bool isPending;
  final bool isAdmin;

  void _confirmarRemocao(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.removeMemberTitle),
        content: Text(l10n.removeMemberConfirm(membro.nome)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(casaControllerProvider.notifier)
                  .removerMembro(casaId, membro.userId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final podeRemover = isAdmin &&
        !isPending &&
        membro.userId != currentUserId;
    final (memberColor, onMemberColor) =
        AppColors.memberColorFor(membro.userId, theme.brightness);

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: memberColor,
          backgroundImage: membro.fotoUrl != null
              ? CachedNetworkImageProvider(membro.fotoUrl!)
              : null,
          child: membro.fotoUrl == null
              ? Text(
                  membro.nome[0].toUpperCase(),
                  style: TextStyle(color: onMemberColor),
                )
              : null,
        ),
        title: Text(membro.nome),
        subtitle: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(child: Text(membro.cargo)),
            // Non-admin viewers see no approve/reject icons on a pending
            // row (admin-gated below) — this pill is the "what does a
            // non-admin see instead" cue that the row is in a different
            // state (docs/DESIGN.md §4.6).
            if (isPending) ...[
              const SizedBox(width: AppSpacing.sm),
              const _PendenteChip(),
            ],
          ],
        ),
        trailing: isPending && isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: l10n.approveTooltip,
                    icon: const Icon(Icons.check_circle_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => ref
                        .read(casaControllerProvider.notifier)
                        .aprovarMembro(casaId, membro.userId),
                  ),
                  IconButton(
                    tooltip: l10n.rejectTooltip,
                    icon: const Icon(Icons.cancel_rounded),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => ref
                        .read(casaControllerProvider.notifier)
                        .recusarMembro(casaId, membro.userId),
                  ),
                ],
              )
            : podeRemover
                ? IconButton(
                    tooltip: l10n.removeMemberTitle,
                    icon: const Icon(Icons.person_remove_outlined),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => _confirmarRemocao(context, ref),
                  )
                : null,
      ),
    );
  }
}

/// Outlined "Pendente" pill (docs/DESIGN.md §4.6) — `border` token outline,
/// `inkSubtle` text, no fill.
class _PendenteChip extends StatelessWidget {
  const _PendenteChip();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final inkSubtle =
        isDark ? AppColors.inkSubtleDark : AppColors.inkSubtleLight;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.outline),
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Text(
        AppLocalizations.of(context)!.pendingChip,
        style: theme.textTheme.labelMedium?.copyWith(color: inkSubtle),
      ),
    );
  }
}

class _ConfirmarDelecaoDialog extends StatefulWidget {
  const _ConfirmarDelecaoDialog({
    required this.nomeCasa,
    required this.isGoogleUser,
    required this.onConfirm,
  });

  final String nomeCasa;
  final bool isGoogleUser;
  final VoidCallback onConfirm;

  @override
  State<_ConfirmarDelecaoDialog> createState() =>
      _ConfirmarDelecaoDialogState();
}

class _ConfirmarDelecaoDialogState extends State<_ConfirmarDelecaoDialog> {
  final _nomeController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isLoading = false;
  String? _erro;

  bool get _nomeValido => _nomeController.text == widget.nomeCasa;
  bool get _senhaValida =>
      widget.isGoogleUser || _senhaController.text.isNotEmpty;
  bool get _podeConfirmar => _nomeValido && _senhaValida && !_isLoading;

  @override
  void dispose() {
    _nomeController.dispose();
    _senhaController.dispose();
    super.dispose();
  }

  Future<void> _confirmar() async {
    if (!_podeConfirmar) return;
    setState(() {
      _isLoading = true;
      _erro = null;
    });

    if (!widget.isGoogleUser) {
      try {
        final user = FirebaseAuth.instance.currentUser!;
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: _senhaController.text,
        );
        await user.reauthenticateWithCredential(credential);
      } on FirebaseAuthException {
        setState(() {
          _isLoading = false;
          _erro = AppLocalizations.of(context)!.wrongPasswordError;
        });
        return;
      }
    }

    widget.onConfirm();
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return AlertDialog(
      title: Text(l10n.deleteHouseTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.deleteHouseConfirmBody),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nomeController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: l10n.houseNameLabel,
                hintText: widget.nomeCasa,
                helperText: l10n.houseNameHelper(widget.nomeCasa),
              ),
            ),
            if (!widget.isGoogleUser) ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _senhaController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _confirmar(),
                decoration: InputDecoration(
                  labelText: l10n.yourPasswordLabel,
                ),
              ),
            ],
            if (_erro != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                _erro!,
                style: TextStyle(
                  color: theme.colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _podeConfirmar ? _confirmar : null,
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.error,
            foregroundColor: theme.colorScheme.onError,
            minimumSize: const Size(88, 44),
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onError,
                  ),
                )
              : Text(l10n.delete),
        ),
      ],
    );
  }
}
