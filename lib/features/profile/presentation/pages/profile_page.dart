import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../casa/domain/models/casa_model.dart';
import '../../../casa/domain/models/membro_model.dart';
import '../../../casa/presentation/providers/casa_provider.dart';
import '../../../../shared/widgets/domo_leading_logo.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).valueOrNull;
    final casaAsync = ref.watch(casaDoUsuarioProvider);

    if (user == null) return const Scaffold(body: SizedBox.shrink());

    return casaAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (casa) => _ProfileContent(user: user, casa: casa),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user, required this.casa});

  final User user;
  final CasaModel? casa;

  MembroModel? _meuMembro(List<MembroModel> membros) {
    return membros.cast<MembroModel?>().firstWhere(
          (m) => m?.userId == user.uid,
          orElse: () => null,
        );
  }

  void _confirmarSaida(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final membros = casa != null
        ? ref.watch(membrosProvider(casa!.id)).valueOrNull ?? []
        : <MembroModel>[];

    final meuMembro = _meuMembro(membros);

    return Scaffold(
      appBar: AppBar(
        leading: const DomoLeadingLogo(),
        leadingWidth: 72,
        title: const Text('Perfil'),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xl,
                horizontal: AppSpacing.lg,
              ),
              child: Column(
                children: [
                  _Avatar(
                    photoUrl: user.photoURL,
                    nome: user.displayName ?? user.email ?? '?',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.displayName ?? 'Usuário',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (user.email != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      user.email!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (casa != null) ...[
              _SectionLabel('Na casa', theme),
              _CardSection(
                children: [
                  _InfoTile(
                    icon: Icons.home_outlined,
                    label: 'Nome da casa',
                    value: casa!.nome,
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: 'Cargo',
                    value: meuMembro?.cargo.isNotEmpty == true
                        ? meuMembro!.cargo
                        : '—',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            _SectionLabel('Conta', theme),
            _CardSection(
              children: [
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    'Sair',
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _confirmarSaida(context, ref),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.nome});

  final String? photoUrl;
  final String nome;

  @override
  Widget build(BuildContext context) {
    const radius = 52.0;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(photoUrl!),
        onBackgroundImageError: (_, _) {},
        backgroundColor: AppColors.primary,
      );
    }

    return _Initials(nome: nome, radius: radius);
  }
}

class _Initials extends StatelessWidget {
  const _Initials({required this.nome, required this.radius});

  final String nome;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: AppColors.onPrimary,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label, this.theme);

  final String label;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.primary,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _CardSection extends StatelessWidget {
  const _CardSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Card(
        margin: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      subtitle: Text(value),
    );
  }
}
