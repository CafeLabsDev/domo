import 'package:cached_network_image/cached_network_image.dart';
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
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(casaControllerProvider.notifier).sairDaCasa(casaId);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, WidgetRef ref, String casaId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar casa'),
        content: const Text(
          'Todos os membros perderão o acesso. Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(casaControllerProvider.notifier).deletarCasa(casaId);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Deletar'),
          ),
        ],
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
                    _confirmarExclusao(context, ref, casa.id);
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
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(casaControllerProvider.notifier)
                  .removerMembro(casaId, membro.userId);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
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
