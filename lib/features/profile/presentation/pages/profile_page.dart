import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/locale_provider.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../auth/presentation/providers/auth_controller.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../casa/domain/models/casa_model.dart';
import '../../../casa/domain/models/membro_model.dart';
import '../../../casa/presentation/providers/casa_provider.dart';
import '../../../../shared/widgets/domo_error_state.dart';
import '../../../../shared/widgets/domo_leading_logo.dart' show DomoPageTitle;

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
      error: (e, _) => Scaffold(
        body: DomoErrorState(
          title: AppLocalizations.of(context)!.couldNotLoadHouse,
          onRetry: () => ref.invalidate(casaDoUsuarioProvider),
        ),
      ),
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
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.signOutConfirmTitle),
        content: Text(l10n.signOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authControllerProvider.notifier).signOut();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(ctx).colorScheme.error,
            ),
            child: Text(l10n.signOut),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final membros = casa != null
        ? ref.watch(membrosProvider(casa!.id)).valueOrNull ?? []
        : <MembroModel>[];

    final meuMembro = _meuMembro(membros);

    return Scaffold(
      appBar: AppBar(
        title: DomoPageTitle(l10n.profileTitle),
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
                    userId: user.uid,
                    photoUrl: user.photoURL,
                    nome: user.displayName ?? user.email ?? '?',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    user.displayName ?? l10n.defaultUserName,
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
              _SectionLabel(l10n.inHouseSection, theme),
              _CardSection(
                children: [
                  _InfoTile(
                    icon: Icons.home_outlined,
                    label: l10n.houseNameField,
                    value: casa!.nome,
                  ),
                  const Divider(height: 1, indent: 56),
                  _InfoTile(
                    icon: Icons.badge_outlined,
                    label: l10n.roleField,
                    value: meuMembro?.cargo.isNotEmpty == true
                        ? meuMembro!.cargo
                        : '—',
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],

            _SectionLabel(l10n.appearanceSection, theme),
            _CardSection(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: const Icon(Icons.brightness_auto_outlined),
                        label: Text(l10n.systemTheme),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: const Icon(Icons.light_mode_outlined),
                        label: Text(l10n.lightTheme),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: const Icon(Icons.dark_mode_outlined),
                        label: Text(l10n.darkTheme),
                      ),
                    ],
                    selected: {ref.watch(themeModeProvider)},
                    onSelectionChanged: (set) {
                      ref.read(themeModeProvider.notifier).state = set.first;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _SectionLabel(l10n.languageSection, theme),
            _CardSection(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: SegmentedButton<Locale?>(
                    segments: [
                      ButtonSegment(
                        value: null,
                        icon: const Icon(Icons.brightness_auto_outlined),
                        label: Text(l10n.languageSystemOption),
                      ),
                      const ButtonSegment(
                        value: Locale('pt'),
                        label: Text('Português'),
                      ),
                      const ButtonSegment(
                        value: Locale('en'),
                        label: Text('English'),
                      ),
                    ],
                    selected: {ref.watch(localeProvider)},
                    onSelectionChanged: (set) {
                      ref.read(localeProvider.notifier).state = set.first;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            _SectionLabel(l10n.accountSection, theme),
            _CardSection(
              children: [
                ListTile(
                  leading: Icon(Icons.logout, color: theme.colorScheme.error),
                  title: Text(
                    l10n.signOut,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                  onTap: () => _confirmarSaida(context, ref),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),
            Text(
              l10n.footerBrand,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.brightness == Brightness.dark
                    ? AppColors.inkSubtleDark
                    : AppColors.inkSubtleLight,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.userId,
    required this.photoUrl,
    required this.nome,
  });

  final String userId;
  final String? photoUrl;
  final String nome;

  @override
  Widget build(BuildContext context) {
    const radius = 52.0;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      final (memberColor, _) = AppColors.memberColorFor(
        userId,
        Theme.of(context).brightness,
      );
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(photoUrl!),
        onBackgroundImageError: (_, _) {},
        backgroundColor: memberColor,
      );
    }

    return _Initials(userId: userId, nome: nome, radius: radius);
  }
}

/// Member-color avatar (docs/DESIGN.md §1.3/§4.6) — deterministic per
/// `userId`, "this is the whole house's list, not mine" signal.
class _Initials extends StatelessWidget {
  const _Initials({
    required this.userId,
    required this.nome,
    required this.radius,
  });

  final String userId;
  final String nome;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initial = nome.isNotEmpty ? nome[0].toUpperCase() : '?';
    final (bgColor, onColor) = AppColors.memberColorFor(
      userId,
      Theme.of(context).brightness,
    );
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Text(
        initial,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w700,
          color: onColor,
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
