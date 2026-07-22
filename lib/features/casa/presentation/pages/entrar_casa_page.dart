import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/casa_controller.dart';

class EntrarCasaPage extends ConsumerStatefulWidget {
  const EntrarCasaPage({super.key});

  @override
  ConsumerState<EntrarCasaPage> createState() => _EntrarCasaPageState();
}

class _EntrarCasaPageState extends ConsumerState<EntrarCasaPage> {
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();

  @override
  void dispose() {
    _codigoController.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(casaControllerProvider.notifier)
        .entrarNaCasa(_codigoController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(casaControllerProvider).isLoading;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    ref.listen(casaControllerProvider, (_, state) {
      if (state.hasError) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(state.error.toString()),
              behavior: SnackBarBehavior.floating,
            ),
          );
      } else if (!state.isLoading && !state.hasError) {
        ScaffoldMessenger.of(context)
          ..clearSnackBars()
          ..showSnackBar(
            SnackBar(
              content: Text(l10n.joinRequestSent),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.joinHouseTitle),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l10n.joinHouseInstructions,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _codigoController,
                      textCapitalization: TextCapitalization.characters,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _entrar(),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[A-Za-z0-9]'),
                        ),
                        LengthLimitingTextInputFormatter(6),
                        _UpperCaseFormatter(),
                      ],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        letterSpacing: 8,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        labelText: l10n.inviteCode,
                        hintText: l10n.inviteCodeHint,
                        prefixIcon: const Icon(Icons.vpn_key_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.inviteCodeRequired;
                        }
                        if (v.trim().length != 6) {
                          return l10n.inviteCodeWrongLength;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _entrar,
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: theme.colorScheme.onPrimary,
                              ),
                            )
                          : Text(l10n.requestJoinButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
