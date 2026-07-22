import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:domo/l10n/app_localizations.dart';
import 'package:domo/shared/widgets/domo_error_state.dart';

void main() {
  testWidgets('renderiza título, mensagem padrão e botão de retry',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DomoErrorState(
            title: 'Não foi possível carregar sua dispensa.',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.text('Não foi possível carregar sua dispensa.'), findsOneWidget);
    expect(
      find.text('Verifique sua conexão com a internet e tente novamente.'),
      findsOneWidget,
    );
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  testWidgets('nunca mostra a exceção crua — sempre a mensagem custom quando informada',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DomoErrorState(
            title: 'Erro',
            message: 'mensagem amigável',
            onRetry: () {},
          ),
        ),
      ),
    );

    expect(find.text('mensagem amigável'), findsOneWidget);
    expect(find.textContaining('Exception'), findsNothing);
  });

  testWidgets('tocar em "Tentar novamente" chama onRetry', (tester) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('pt'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DomoErrorState(
            title: 'Erro',
            onRetry: () => retried = true,
          ),
        ),
      ),
    );

    await tester.tap(find.text('Tentar novamente'));
    await tester.pump();

    expect(retried, isTrue);
  });
}
