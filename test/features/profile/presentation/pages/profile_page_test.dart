import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:domo/core/providers/locale_provider.dart';
import 'package:domo/features/auth/presentation/providers/auth_provider.dart';
import 'package:domo/features/casa/presentation/providers/casa_provider.dart';
import 'package:domo/features/profile/presentation/pages/profile_page.dart';
import 'package:domo/l10n/app_localizations.dart';

class _MockUser extends Mock implements User {}

void main() {
  late _MockUser user;

  setUp(() {
    user = _MockUser();
    when(() => user.uid).thenReturn('u1');
    when(() => user.displayName).thenReturn('Felipe');
    when(() => user.email).thenReturn('felipe@example.com');
    when(() => user.photoURL).thenReturn(null);
  });

  // localeProvider is seeded to a known value (not left at its real default
  // of null/"follow system") — the widget-test binding resolves "system" to
  // whatever locale the machine running the tests is set to, which isn't pt
  // on every machine/CI runner. Same reasoning as the fix applied to the
  // other widget tests after the i18n rollout (see git history).
  Future<void> pumpPage(WidgetTester tester, {required Locale startLocale}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => Stream.value(user)),
          casaDoUsuarioProvider.overrideWith((ref) => Stream.value(null)),
          localeProvider.overrideWith((ref) => startLocale),
        ],
        // Reads localeProvider the same way DomoApp's real MaterialApp.router
        // does — this is what makes "tap English -> UI actually switches"
        // an end-to-end check of the Profile selector, not just a check
        // that the provider's state changed in isolation.
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(localeProvider),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const ProfilePage(),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renderiza a seção "Idioma" e o rótulo pt quando o locale é pt',
      (tester) async {
    await pumpPage(tester, startLocale: const Locale('pt'));

    // _SectionLabel uppercases its text.
    expect(find.text('IDIOMA'), findsOneWidget);
    expect(find.text('Sair'), findsWidgets); // section label + button, pt
  });

  testWidgets('tocar em "English" troca o locale do app e a UI re-renderiza em inglês',
      (tester) async {
    await pumpPage(tester, startLocale: const Locale('pt'));

    expect(find.text('Sair'), findsWidgets);
    expect(find.text('Sign out'), findsNothing);

    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    expect(find.text('Sign out'), findsWidgets);
    expect(find.text('Sair'), findsNothing);
    expect(find.text('LANGUAGE'), findsOneWidget);
  });

  testWidgets('tocar em "Português" depois de já estar em inglês volta pro pt',
      (tester) async {
    await pumpPage(tester, startLocale: const Locale('en'));

    expect(find.text('Sign out'), findsWidgets);

    await tester.tap(find.text('Português'));
    await tester.pumpAndSettle();

    expect(find.text('Sair'), findsWidgets);
    expect(find.text('Sign out'), findsNothing);
  });
}
