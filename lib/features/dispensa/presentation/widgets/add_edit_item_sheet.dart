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
  late final TextEditingController _quantidadeController;
  late final TextEditingController _estoqueMinimoController;
  late String _categoria;
  late bool _controlaEstoque;
  bool _isLoading = false;
  String? _nomeError;
  String? _quantidadeError;
  String? _saveError;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.item?.nome ?? '');
    _categoria = widget.item?.categoria ?? kDispensaCategorias.last;
    _controlaEstoque = widget.item?.controlaEstoque ?? false;
    _quantidadeController = TextEditingController(
      text: widget.item?.quantidade?.toString() ?? '',
    );
    _estoqueMinimoController = TextEditingController(
      text: widget.item?.estoqueMinimo?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _quantidadeController.dispose();
    _estoqueMinimoController.dispose();
    super.dispose();
  }

  /// Toggle-on UX (product spec): pre-fill quantidade/estoqueMinimo so the
  /// derived status doesn't jarringly flip on activation — "tem" preserves
  /// as quantidade=2/estoqueMinimo=1, anything else (falta/no carrinho)
  /// preserves as quantidade=0/estoqueMinimo=1. Only applied the first time
  /// the switch flips on (fields still empty); if the user toggles off and
  /// back on within the same sheet session, whatever they'd already typed is
  /// kept.
  void _onControlaEstoqueChanged(bool value) {
    setState(() {
      _controlaEstoque = value;
      _quantidadeError = null;
      if (value &&
          _quantidadeController.text.isEmpty &&
          _estoqueMinimoController.text.isEmpty) {
        final statusAtual = widget.item?.status ?? ItemStatus.naoTem;
        if (statusAtual == ItemStatus.tem) {
          _quantidadeController.text = '2';
          _estoqueMinimoController.text = '1';
        } else {
          _quantidadeController.text = '0';
          _estoqueMinimoController.text = '1';
        }
      }
    });
  }

  Future<void> _save() async {
    final nome = _nomeController.text.trim();
    if (nome.isEmpty) {
      setState(() {
        _nomeError = 'Digite um nome para o item.';
        _saveError = null;
      });
      return;
    }

    int? quantidade;
    int? estoqueMinimo;
    if (_controlaEstoque) {
      quantidade = int.tryParse(_quantidadeController.text.trim());
      estoqueMinimo = int.tryParse(_estoqueMinimoController.text.trim());
      if (quantidade == null ||
          quantidade < 0 ||
          estoqueMinimo == null ||
          estoqueMinimo < 0) {
        setState(() {
          _quantidadeError =
              'Informe quantidade e estoque mínimo (0 ou mais).';
          _saveError = null;
        });
        return;
      }
    }

    setState(() {
      _isLoading = true;
      _nomeError = null;
      _quantidadeError = null;
      _saveError = null;
    });

    try {
      final repo = ref.read(dispensaRepositoryProvider);
      final user = ref.read(authStateProvider).valueOrNull;

      if (_isEditing) {
        final item = widget.item!;
        await repo.atualizarItem(
          casaId: widget.casaId,
          itemId: item.id,
          nome: nome,
          categoria: _categoria,
        );

        if (user != null) {
          if (_controlaEstoque && !item.controlaEstoque) {
            await repo.ativarControleEstoque(
              casaId: widget.casaId,
              itemId: item.id,
              quantidade: quantidade!,
              estoqueMinimo: estoqueMinimo!,
              userId: user.uid,
            );
          } else if (!_controlaEstoque && item.controlaEstoque) {
            await repo.desativarControleEstoque(
              casaId: widget.casaId,
              itemId: item.id,
              statusCongelado: item.status,
              userId: user.uid,
            );
          } else if (_controlaEstoque &&
              item.controlaEstoque &&
              (quantidade != item.quantidade ||
                  estoqueMinimo != item.estoqueMinimo)) {
            await repo.atualizarQuantidade(
              casaId: widget.casaId,
              itemId: item.id,
              quantidade: quantidade!,
              estoqueMinimo: estoqueMinimo!,
              userId: user.uid,
            );
          }
        }
      } else {
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
      if (mounted) {
        setState(() {
          _isLoading = false;
          _saveError = 'Não foi possível salvar. Tente novamente.';
        });
      }
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
            onChanged: (_) {
              if (_nomeError != null) setState(() => _nomeError = null);
            },
            decoration: InputDecoration(
              labelText: 'Nome do item',
              hintText: 'Ex: Leite integral',
              errorText: _nomeError,
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
          // Quantity/minimum-stock control is opt-in and only makes sense for
          // an item that already exists (the toggle calls
          // ativarControleEstoque/desativarControleEstoque, which need an
          // itemId) — a brand-new item is created OFF, same as before.
          if (_isEditing) ...[
            const SizedBox(height: AppSpacing.sm),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Controlar quantidade'),
              subtitle: const Text(
                'Acompanhe a quantidade e um estoque mínimo deste item.',
              ),
              value: _controlaEstoque,
              onChanged: _onControlaEstoqueChanged,
            ),
            if (_controlaEstoque) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _quantidadeController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (_quantidadeError != null) {
                          setState(() => _quantidadeError = null);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Quantidade',
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _estoqueMinimoController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (_quantidadeError != null) {
                          setState(() => _quantidadeError = null);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Estoque mínimo',
                      ),
                    ),
                  ),
                ],
              ),
              if (_quantidadeError != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _quantidadeError!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
            ],
          ],
          if (_saveError != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              _saveError!,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xl),
          FilledButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.onPrimary,
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
