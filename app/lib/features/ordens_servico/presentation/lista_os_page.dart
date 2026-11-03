import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';

class ListaOsPage extends StatelessWidget {
  const ListaOsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ordens de Serviço'),
        actions: [
          IconButton(
            tooltip: 'Configurações',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(Rotas.configuracoes),
          ),
        ],
      ),
      body: const Center(child: Text('Nenhuma OS cadastrada ainda.')),
    );
  }
}
