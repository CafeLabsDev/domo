import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/constants.dart';
import '../../domain/models/pantry_item.dart';
import '../providers/dispensa_provider.dart';

class AddEditItemSheet extends ConsumerStatefulWidget {
  const AddEditItemSheet({
    super.key,
    required this.casaId,
    this.item,
  });

  final String casaId;
  final PantryItem? item;

  @override
  ConsumerState<AddEditItemSheet> createState() => _AddEditItemSheetState();
}

class _AddEditItemSheetState extends ConsumerState<AddEditItemSheet> {
  late final TextEditingController _nomeController;
  late String _categoria;
  bool _isLoading = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _categoria = widget.item?.categoria ?? kDispensaCategorias.last;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(dispensaRepositoryProvider);

      if (_isEditing) {
        await repo.atualizarItem(
          casaId: widget.casaId,
          itemId: widget.item!.id,
          nome: nome,
          categoria: _categoria,
        );
      } else {
        final user = ref.read(authStateProvider).valueOrNull;
        if (user == null) return;
        await repo.adicionarItem(
          casaId: widget.casaId,
          nome: nome,
          categoria: _categoria,
          userId: user.uid,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                _isEditing ? 'Editar item' : 'Novo item',
                style: theme.textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _nomeController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Nome do item',
              hintText: 'Ex: Leite integral',
            ),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.md),
          DropdownMenu<String>(
            initialSelection: _categoria,
            label: const Text('Categoria'),
            expandedInsets: EdgeInsets.zero,
            onSelected: (v) {
              if (v != null) setState(() => _categoria = v);
            },
            dropdownMenuEntries: kDispensaCategorias
                .map((c) => DropdownMenuEntry(value: c, label: c))
                .toList(),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(_isEditing ? 'Salvar' : 'Adicionar'),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}
