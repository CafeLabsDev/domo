import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/casa/presentation/pages/casa_gate_page.dart';
import '../../features/casa/presentation/pages/casa_page.dart';
import '../../features/casa/presentation/pages/criar_casa_page.dart';
import '../../features/casa/presentation/pages/entrar_casa_page.dart';
import '../../features/casa/presentation/providers/casa_provider.dart';
import '../../features/dispensa/presentation/pages/dispensa_page.dart';
import '../../features/mercado/presentation/pages/mercado_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../shared/widgets/home_shell.dart';

part 'app_router.g.dart';

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authNotifier = _RouterNotifier(ref);

  return GoRouter(
    refreshListenable: authNotifier,
    initialLocation: '/dispensa',
    redirect: (context, state) {
      final user = ref.read(authStateProvider).valueOrNull;
      final isLoggedIn = user != null;
      final path = state.matchedLocation;

      final isOnAuth = path.startsWith('/auth');
      final isOnCasaGate = path.startsWith('/casa/gate') ||
          path.startsWith('/casa/criar') ||
          path.startsWith('/casa/entrar');

      // Não logado → login
      if (!isLoggedIn && !isOnAuth) return '/auth/login';

      // Logado mas na tela de auth → verificar casa
      if (isLoggedIn && isOnAuth) {
        final casaAsync = ref.read(casaDoUsuarioProvider);
        if (casaAsync.isLoading) return null;
        final casa = casaAsync.valueOrNull;
        return casa != null ? '/dispensa' : '/casa/gate';
      }

      // Logado e fora de auth → verificar se tem casa
      if (isLoggedIn && !isOnAuth && !isOnCasaGate) {
        final casaAsync = ref.read(casaDoUsuarioProvider);
        if (casaAsync.isLoading) return null;
        final casa = casaAsync.valueOrNull;
        if (casa == null) return '/casa/gate';
      }

      // Logado, tem casa, mas ainda na gate → ir para home
      if (isLoggedIn && isOnCasaGate) {
        final casaAsync = ref.read(casaDoUsuarioProvider);
        if (casaAsync.isLoading) return null;
        final casa = casaAsync.valueOrNull;
        if (casa != null) return '/dispensa';
      }

      return null;
    },
    routes: [
      // Auth
      GoRoute(
        path: '/auth/login',
        builder: (_, _) => const LoginPage(),
      ),
      GoRoute(
        path: '/auth/register',
        builder: (_, _) => const RegisterPage(),
      ),

      // Casa gate (sem nav bar)
      GoRoute(
        path: '/casa/gate',
        builder: (_, _) => const CasaGatePage(),
      ),
      GoRoute(
        path: '/casa/criar',
        builder: (_, _) => const CriarCasaPage(),
      ),
      GoRoute(
        path: '/casa/entrar',
        builder: (_, _) => const EntrarCasaPage(),
      ),

      // Home shell com nav bar
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/dispensa',
              builder: (_, _) => const DispensaPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/mercado',
              builder: (_, _) => const MercadoPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/casa',
              builder: (_, _) => const CasaPage(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/perfil',
              builder: (_, _) => const ProfilePage(),
            ),
          ]),
        ],
      ),
    ],
  );
}

class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(Ref ref) {
    ref.listen(authStateProvider, (_, _) => notifyListeners());
    ref.listen(casaDoUsuarioProvider, (_, _) => notifyListeners());
  }
}
