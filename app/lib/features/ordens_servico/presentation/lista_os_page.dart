import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/rotas.dart';
import '../../../core/theme/estilos.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../domain/formatos_os.dart';
import '../domain/status_os.dart';
import 'widgets/cartao_gravar_os.dart';
import 'widgets/etiqueta_status.dart';

/// TEMPORÁRIO: vitrine dos componentes visuais.
/// Será substituída pela lista de OS de verdade.
class ListaOsPage extends StatelessWidget {
  const ListaOsPage({super.key});

  void _emBreve(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A gravação por áudio chega na Fase 2.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final titulo = Theme.of(context).textTheme.titleMedium;

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
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Cartão principal', style: titulo),
          const SizedBox(height: 12),
          CartaoGravarOs(onTap: () => _emBreve(context)),
          const SizedBox(height: 24),
          Text('Alternativa suave (só no tema claro)', style: titulo),
          const SizedBox(height: 12),
          CartaoGravarOs(suave: true, onTap: () => _emBreve(context)),
          const SizedBox(height: 24),
          Text('Status', style: titulo),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final status in StatusOs.values) EtiquetaStatus(status),
            ],
          ),
          const SizedBox(height: 24),
          Text('Número da OS', style: titulo),
          const SizedBox(height: 12),
          Text(
            '${formatarNumeroOs(128)} · hoje 14:32',
            style: context.estiloNumeroOs,
          ),
          const SizedBox(height: 24),
          Text('Avatares', style: titulo),
          const SizedBox(height: 12),
          const Wrap(
            spacing: 8,
            children: [
              AvatarIniciais(nome: 'Euzébio Souza'),
              AvatarIniciais(nome: 'Marina Costa'),
              AvatarIniciais(nome: 'Carlos Menezes'),
              AvatarIniciais(nome: 'Ana Beatriz Lima'),
            ],
          ),
        ],
      ),
    );
  }
}
