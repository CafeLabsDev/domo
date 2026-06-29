import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/casa/presentation/pages/casa_page.dart';
import '../../features/dispensa/presentation/pages/dispensa_page.dart';
import '../../features/mercado/presentation/pages/mercado_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/home_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = _AuthNotifier(ref);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/dispensa',
    redirect: (context, state) {
      final user = ref.read(authStateProvider).valueOrNull;
      final isLoggedIn = user != null;
      final isOnAuth = state.matchedLocation.startsWith('/auth');

      if (!isLoggedIn && !isOnAuth) return '/auth/login';
      if (isLoggedIn && isOnAuth) return '/dispensa';
      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, _) => const RegisterPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/dispensa', builder: (_, _) => const DispensaPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/mercado', builder: (_, _) => const MercadoPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/casa', builder: (_, _) => const CasaPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/perfil', builder: (_, _) => const ProfilePage()),
          ]),
        ],
      ),
    ],
  );
}

class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
  }
}
