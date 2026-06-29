import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/membro_model.dart';
import '../providers/casa_controller.dart';
import '../providers/casa_provider.dart';

class CasaPage extends ConsumerWidget {
  const CasaPage({super.key});

  void _copiarCodigo(BuildContext context, String codigo) {
    Clipboard.setData(ClipboardData(text: codigo));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('Código copiado!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  void _confirmarSaida(BuildContext context, WidgetRef ref, String casaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair da casa'),
        content: const Text(
          'Você vai perder o acesso a esta casa. Para voltar, precisará do código de convite.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(casaControllerProvider.notifier).sairDaCasa(casaId);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: const Text('Sair'),
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

    return casaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Erro: $e')),
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
            title: Text(casa.nome),
            centerTitle: false,
            actions: [
              IconButton(
                tooltip: 'Copiar código',
                icon: const Icon(Icons.share_rounded),
                onPressed: () => _copiarCodigo(context, casa.codigo),
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
                    const PopupMenuItem(
                      value: _MenuAcao.sair,
                      child: ListTile(
                        leading: Icon(Icons.logout),
                        title: Text('Sair da casa'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  if (isAdmin)
                    PopupMenuItem(
                      value: _MenuAcao.deletar,
                      child: ListTile(
                        leading: Icon(Icons.delete_forever,
                            color: AppColors.error),
                        title: Text(
                          'Deletar casa',
                          style: TextStyle(color: AppColors.error),
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
                          'Código de convite',
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
                              .titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 6,
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
                  error: (e, _) => Center(child: Text('Erro: $e')),
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
                            'Aguardando aprovação (${pendentes.length})',
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
                        _SectionHeader('Membros (${ativos.length})'),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover membro'),
        content: Text(
          'Deseja remover ${membro.nome} da casa? '
          'Eles perderão o acesso imediatamente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
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
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final podeRemover = isAdmin &&
        !isPending &&
        membro.userId != currentUserId;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: membro.fotoUrl != null
              ? CachedNetworkImageProvider(membro.fotoUrl!)
              : null,
          child: membro.fotoUrl == null
              ? Text(membro.nome[0].toUpperCase())
              : null,
        ),
        title: Text(membro.nome),
        subtitle: Text(membro.cargo),
        trailing: isPending && isAdmin
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip: 'Aprovar',
                    icon: const Icon(Icons.check_circle_rounded),
                    color: Theme.of(context).colorScheme.primary,
                    onPressed: () => ref
                        .read(casaControllerProvider.notifier)
                        .aprovarMembro(casaId, membro.userId),
                  ),
                  IconButton(
                    tooltip: 'Recusar',
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
                    tooltip: 'Remover membro',
                    icon: const Icon(Icons.person_remove_outlined),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => _confirmarRemocao(context, ref),
                  )
                : null,
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
          _erro = 'Senha incorreta. Verifique e tente novamente.';
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

    return AlertDialog(
      title: const Text('Deletar casa'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Esta ação é permanente e não pode ser desfeita. '
              'Todos os membros perderão o acesso.',
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _nomeController,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Nome da casa',
                hintText: widget.nomeCasa,
                helperText: 'Digite exatamente: ${widget.nomeCasa}',
              ),
            ),
            if (!widget.isGoogleUser) ...[
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _senhaController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                onSubmitted: (_) => _confirmar(),
                decoration: const InputDecoration(
                  labelText: 'Sua senha',
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
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _podeConfirmar ? _confirmar : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
            minimumSize: const Size(88, 44),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Deletar'),
        ),
      ],
    );
  }
}
