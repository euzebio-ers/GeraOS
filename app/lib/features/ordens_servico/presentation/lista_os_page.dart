import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';

/// Provisória: a lista de verdade chega na parte 8.4.
class ListaOsPage extends StatelessWidget {
  const ListaOsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton.filled(
              tooltip: 'Nova OS',
              onPressed: () => context.push(Rotas.novaOs),
              icon: const Icon(Icons.add_rounded),
            ),
          ),
        ],
      ),
      body: const Center(child: Text('Nenhuma OS cadastrada ainda.')),
    );
  }
}
