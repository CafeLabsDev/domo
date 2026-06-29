import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/membro_model.dart';
import '../providers/casa_controller.dart';
import '../providers/casa_provider.dart';

class CasaPage extends ConsumerWidget {
  const CasaPage({super.key});

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
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: casa.codigo));
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Código copiado!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                },
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
    required this.isPending,
    required this.isAdmin,
  });

  final MembroModel membro;
  final String casaId;
  final bool isPending;
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            : null,
      ),
    );
  }
}
