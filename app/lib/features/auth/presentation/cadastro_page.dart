import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Criar conta')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('O cadastro será implementado na Etapa 6.'),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go(Rotas.login),
                child: const Text('Já tenho conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
