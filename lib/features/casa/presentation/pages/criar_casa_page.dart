import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/casa_controller.dart';

class CriarCasaPage extends ConsumerStatefulWidget {
  const CriarCasaPage({super.key});

  @override
  ConsumerState<CriarCasaPage> createState() => _CriarCasaPageState();
}

class _CriarCasaPageState extends ConsumerState<CriarCasaPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) return;
    await ref
        .read(casaControllerProvider.notifier)
        .criarCasa(_nomeController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(casaControllerProvider).isLoading;
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
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.newHouseTitle),
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
                      l10n.houseNameQuestion,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextFormField(
                      controller: _nomeController,
                      textCapitalization: TextCapitalization.words,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _criar(),
                      decoration: InputDecoration(
                        labelText: l10n.houseNameLabel,
                        prefixIcon: const Icon(Icons.home_rounded),
                        hintText: l10n.houseNameHint,
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return l10n.houseNameRequired;
                        }
                        if (v.trim().length < 3) {
                          return l10n.houseNameTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _criar,
                      child: isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            )
                          : Text(l10n.createHouseSubmit),
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
