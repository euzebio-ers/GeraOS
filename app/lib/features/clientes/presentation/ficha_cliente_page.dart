import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/formatting/documento.dart';
import '../../../core/formatting/telefone.dart';
import '../../../core/router/rotas.dart';
import '../../../core/widgets/avatar_iniciais.dart';
import '../../../core/widgets/botoes_contato.dart';
import '../../../core/widgets/lista_formulario.dart';
import '../../ordens_servico/data/ordens_servico_repository.dart';
import '../../ordens_servico/presentation/widgets/cartao_os.dart';
import '../data/clientes_repository.dart';
import '../domain/cliente.dart';

/// A ficha do cliente: contato, dados e o histórico de OS.
class FichaClientePage extends ConsumerWidget {
  const FichaClientePage({super.key, required this.clienteId});

  final String clienteId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(clienteProvider(clienteId))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (erro, pilha) => Scaffold(
            appBar: AppBar(),
            body: const Center(
              child: Text('Não foi possível carregar o cliente.'),
            ),
          ),
          data: (cliente) => _Ficha(clienteId: clienteId, cliente: cliente),
        );
  }
}

class _Ficha extends ConsumerWidget {
  const _Ficha({required this.clienteId, required this.cliente});

  final String clienteId;
  final Cliente cliente;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final secundario = tema.textTheme.bodyMedium?.copyWith(
      color: tema.colorScheme.onSurfaceVariant,
    );
    final contato = [
      if (cliente.telefone != null) formatarTelefone(cliente.telefone!),
      if (cliente.email != null) cliente.email!,
    ].join(' · ');
    final temDados = cliente.documento != null || cliente.observacoes != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cliente'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: () => context.push(Rotas.editarCliente(clienteId)),
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Editar'),
            ),
          ),
        ],
      ),
      body: ListaFormulario(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Row(
            children: [
              AvatarIniciais(nome: cliente.nome, tamanho: 56),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(cliente.nome, style: tema.textTheme.headlineSmall),
                    if (contato.isNotEmpty) Text(contato, style: secundario),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BotoesContato(telefone: cliente.telefone),
          if (temDados) ...[
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (cliente.documento != null)
                      _Dado(
                        rotulo: 'Documento',
                        valor: documentoComRotulo(cliente.documento!),
                      ),
                    if (cliente.observacoes != null)
                      _Dado(rotulo: 'Observações', valor: cliente.observacoes!),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Text('Histórico de OS', style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          ref
              .watch(osDoClienteProvider(clienteId))
              .when(
                loading: () => const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (erro, pilha) => Text(
                  'Não foi possível carregar as OS deste cliente.',
                  style: secundario,
                ),
                data: (ordens) => ordens.isEmpty
                    ? Text(
                        'Nenhuma OS para este cliente ainda.',
                        style: secundario,
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final os in ordens)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: CartaoOs(
                                os: os,
                                aoTocar: () => context.push(Rotas.os(os.id)),
                              ),
                            ),
                        ],
                      ),
              ),
        ],
      ),
    );
  }
}

/// Um rótulo pequeno em maiúsculas com o valor embaixo.
class _Dado extends StatelessWidget {
  const _Dado({required this.rotulo, required this.valor});

  final String rotulo;
  final String valor;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            rotulo.toUpperCase(),
            style: tema.textTheme.labelMedium?.copyWith(
              color: tema.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 2),
          Text(valor),
        ],
      ),
    );
  }
}
