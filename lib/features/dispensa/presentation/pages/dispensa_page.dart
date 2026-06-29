import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';

class DispensaPage extends StatelessWidget {
  const DispensaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispensa')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Text('Sua dispensa aparecerá aqui.'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: adicionar item
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
