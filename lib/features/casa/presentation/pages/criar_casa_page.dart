import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
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
        title: const Text('Nova Casa'),
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
                      'Como sua casa se chama?',
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
                      decoration: const InputDecoration(
                        labelText: 'Nome da casa',
                        prefixIcon: Icon(Icons.home_rounded),
                        hintText: 'Ex: Família Silva',
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Informe o nome da casa.';
                        }
                        if (v.trim().length < 3) {
                          return 'O nome deve ter pelo menos 3 caracteres.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    FilledButton(
                      onPressed: isLoading ? null : _criar,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Criar Casa'),
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
